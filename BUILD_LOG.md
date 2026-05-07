# Build Log

Session-by-session notes from building the Defender → Sentinel auto-remediation pipeline. Errors, decisions, and lessons captured as they happened.

---

## Architecture Decisions

**Terraform over Bicep.** Provider-agnostic, dominant in the job market, modules reusable for follow-on projects (GitHub Actions OIDC pipeline). Bicep would be slightly tighter Azure-only syntax — only matters in Microsoft-only shops.

**System-assigned managed identity over service principal.** No client secret to leak, rotate, or commit. Token issuance and rotation handled by Azure AD. Scoped to Storage Account Contributor on the resource group, not subscription — least privilege.

**Consumption-tier Logic App.** Pay-per-execution. Remediation playbooks fire on incidents — fractions of a cent per run. Standard tier's fixed monthly cost not justified for low-frequency automation.

**`uaenorth` region.** Lowest-cost regional option. Tradeoff captured below in lessons — connector availability is limited.

---

## Errors & Lessons (the messy version)

### 1. Continuous Export is the critical link nobody talks about

Defender for Cloud findings do **not** automatically land in Sentinel. The pipe between them is Continuous Export, which has to be configured at the subscription level — Defender → Environment Settings → Continuous Export → select Log Analytics workspace → choose data types (`SecurityRecommendation`, `SecureScore`, `SecurityAlert`).

Symptom of missing this: KQL detection rules query empty tables. No incidents ever fire. The pipeline looks broken when it's actually never been wired.

Fix: configure Continuous Export, wait ~5 minutes for first batch, verify with `SecurityRecommendation | take 10` in Log Analytics.

### 2. Sentinel KQL schema validation traps you on fresh workspaces

Sentinel validates analytics rule queries against the **registered table schema** at rule creation time. On a brand-new workspace with no data ingested yet, the schema isn't registered. Any column reference in a `project` statement fails with a confusing error about the column not existing.

Fix: deploy detection rules in two stages. Start with a bare filter query that doesn't project columns. Once data flows in and the schema registers, update the rule to project specific columns.

### 3. `has_any` beats equality for Defender recommendation names

Defender recommendation display names change between API versions. A query that filters with `RecommendationDisplayName == "Storage account public access should be disallowed"` will silently miss findings if Microsoft renames the recommendation slightly.

Fix: use `has_any` with multiple known string variants of the recommendation name. More resilient to upstream renames.

### 4. Logic App ARM API call needs explicit Managed Identity auth, set in the designer

Setting the Logic App identity to system-assigned in Terraform does not automatically configure the HTTP action to *use* that identity. The HTTP action's Authentication property must be explicitly set to `Managed Identity` in the workflow definition. Easy to miss because it's a portal-designer-only screen for first-time setup.

Symptom: Logic App runs, HTTP action fails with `401 Unauthorized` against the ARM endpoint.

Fix: In Logic App Designer → HTTP action → Add new parameter → Authentication → Managed Identity → System-assigned → Audience: `https://management.azure.com/`.

### 5. Role assignment must be on resource group, not subscription

The first instinct is to grant Storage Account Contributor at the subscription level — easier, fewer Terraform resources. Resist. Scope to the specific resource group containing the storage accounts the playbook is allowed to remediate.

Why it matters: if the Logic App is compromised, the blast radius is limited to that RG's storage accounts. Subscription-scoped permissions = full lateral movement.

### 6. UAE North has limited Logic App connector catalog

The Microsoft Sentinel incident connector — the trigger that fires a playbook directly off a Sentinel incident — is **not available** in `uaenorth` at the time of build. The workaround is an HTTP trigger called by an automation rule via Azure Functions or by polling.

Production fix: deploy to `westeurope` or `eastus` where the full connector catalog is available. The pipeline architecture is identical — only the trigger mechanism differs.

Interview answer: this is the kind of regional-availability constraint hiring managers like to probe. Knowing it exists and having a remediation pattern ready is the signal of someone who's actually deployed in production.

### 7. Continuous Export and diagnostic settings are different pipes

Continuous Export pushes Defender data (`SecurityRecommendation`, `SecurityAlert`) into Log Analytics. The subscription Activity Log → Log Analytics diagnostic setting is a *separate* pipe that pushes ARM operations (`AzureActivity` table). Neither one populates the other.

For posture detections that read `SecurityRecommendation`, you only need Continuous Export. For behavioral detections that read `AzureActivity` (NSG rule changes, role assignments), you also need the Activity Log diagnostic setting wired separately.

Both forwarders are **forward-only**. Wiring them after a resource is misbehaving means the historical event is invisible to your detection layer. In production, wire forwarders first and audit existing posture separately via point-in-time scans.

---

## What Production Would Add

Documented in the README "What I'd Do at Production Scale" section. Highlights:

- Multi-subscription coverage via management group policy
- GitHub Actions OIDC for deployment (no stored creds in CI/CD)
- Terraform state in Azure Storage with locking
- Additional remediation playbooks (NSG 22/3389, missing disk encryption, SQL auditing)
- Suppression rules to prevent duplicate incidents
- Enrichment via Azure Resource Graph before remediating (creator, tags, subscription context)
- Approve/Reject Teams flow for higher-risk remediations (NSG rule removal)
- Rollback audit trail — write previous resource state to a custom LAW table before remediating

---

## Cost

Estimated total spend during build: well within Azure free trial $200 credit. Defender plans on 30-day free trial — disabled before day 28 to avoid spillover charges. Logic App consumption tier and Sentinel ingestion stayed nominal at the volume of test data.
