# CLAUDE.md

This file gives Claude Code full context for this project. Read it at the start of every session.

## Project Identity

**Name:** Defender for Cloud → Sentinel Auto-Remediation Pipeline
**Owner:** Hassan
**Purpose:** Portfolio project to land an Azure Cloud Security Engineer / SOC L2 role. This is going on LinkedIn and GitHub as a hiring artifact, not just a learning exercise. Every decision should optimize for "would this impress a hiring manager?"
**Status:** In active build
**Target completion:** ASAP (2 weekends of focused work)

## The Problem This Solves

Cloud environments constantly drift into insecure states — public storage accounts, weak NSG rules, unencrypted disks, disabled firewalls. Misconfiguration is the #1 cause of cloud breaches (Capital One, Microsoft AI research leak, countless ransomware incidents). Companies need three things continuously:
1. **Posture visibility** — what's misconfigured right now
2. **Real-time detection** — alerted the moment something new becomes misconfigured
3. **Automated response** — fixed before an attacker finds it, without paging a human for every finding

Most beginners turn Defender for Cloud on and stop. This project closes the loop: Defender findings → Sentinel → KQL detection → Logic App auto-remediation → Teams/Slack notification. Goal is sub-60-second time from "misconfiguration created" to "misconfiguration fixed" with zero human involvement for known-safe remediations.

## What We're Building (Architecture)

```
Azure Subscription
  └── Defender for Cloud (all plans enabled, trial mode)
        ├── Regulatory compliance: MCSB, CIS Azure Foundations, ISO 27001
        └── Continuous Export ──→ Log Analytics Workspace ──→ Microsoft Sentinel
                                                                    ├── KQL detection rule (new public storage account)
                                                                    ├── Workbook (Secure Score trend + top findings)
                                                                    └── Automation rule ──→ Logic App Playbook
                                                                                                ├── ARM API call: set allowBlobPublicAccess = false
                                                                                                └── Teams/Slack notification
```

## Success Criteria (what "done" looks like)

- [ ] Defender for Cloud enabled, all relevant plans on, regulatory compliance configured
- [ ] Deliberate misconfigurations created and visible as findings (baseline Secure Score captured)
- [ ] Continuous export wired into Log Analytics + Sentinel
- [ ] KQL detection rule fires when a new public storage account is created
- [ ] Logic App playbook auto-remediates and posts to Teams/Slack
- [ ] Sentinel workbook showing Secure Score trend and top 10 findings
- [ ] Everything codified as Terraform modules in this repo (clickops → IaC migration)
- [ ] README with architecture diagram, problem statement, build steps, screenshots, "what I'd do at production scale"
- [ ] LinkedIn post drafted with the story arc
- [ ] Demo video or GIF of the auto-remediation in action (stretch)

## Tech Stack & Constraints

- **Cloud:** Azure (free trial subscription, $200 credit, 30-day Defender trial)
- **IaC:** Terraform with the `azurerm` provider. Chosen over Bicep deliberately: Terraform is dominant in the actual job market, multi-cloud, and the modules written here will be reusable for the next project (Terraform + GitHub Actions OIDC). Bicep would have been slightly tighter with Azure but only matters in Microsoft-only shops.
- **Detection language:** KQL
- **Automation:** Logic Apps (consumption tier to stay in free credit)
- **Notification target:** Teams (preferred) or Slack — whichever Hassan has handy
- **Source control:** GitHub, public repo
- **Deployment:** `az deployment group create` initially, GitHub Actions with OIDC as a stretch goal
- **OS:** [fill in: macOS / Linux / Windows+WSL]

**Cost guardrails:** Everything must stay inside the free trial credit. Defender plans are in 30-day free trial — set a calendar reminder to disable on day 28. Use consumption-tier Logic Apps. No P2 SKUs unless explicitly justified. Tear down expensive resources when not actively building.

## Repo Structure (target)

```
defender-sentinel-project/
├── CLAUDE.md                    # this file
├── README.md                    # the public-facing story
├── BUILD_LOG.md                 # daily notes, surprises, decisions
├── architecture/
│   ├── diagram.mmd              # Mermaid source
│   └── diagram.png              # rendered
├── terraform/
│   ├── main.tf                  # provider, backend, root module wiring
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars         # gitignored, contains sub id + region
│   ├── terraform.tfvars.example # committed template
│   ├── versions.tf              # provider version pins
│   └── modules/
│       ├── log-analytics/
│       ├── sentinel/
│       ├── defender-plans/
│       ├── continuous-export/
│       └── logic-app-remediation/
├── kql/
│   ├── detection-public-storage.kql
│   └── workbook-queries/
├── logic-apps/
│   └── remediate-public-storage.json   # ARM definition
├── screenshots/                 # numbered, descriptive filenames
├── linkedin/
│   ├── post-draft.md
│   └── talking-points.md        # interview prep
└── .github/
    └── workflows/               # stretch: OIDC deploy
```

## Obsidian Note-Taking (Claude Code acts as the project scribe)

Hassan keeps his learning and project notes in Obsidian. Claude Code has access to the Obsidian MCP server and is responsible for keeping a live, detailed log of this project in the vault. Treat this as a core responsibility, not an optional extra — by the end of the project the Obsidian note should read like a work diary that Hassan can paste into an interview prep doc.

**Note location:** `Cloud Security Plan/05b - Hands-On Projects (Azure)/Project 4 - Build Log.md`
(create it on the first session if it doesn't exist; it's a child of the existing Project 4 reference in the Obsidian vault)

**Note structure (use these exact headings so future updates are predictable):**

```markdown
# Project 4 — Defender for Cloud + Sentinel — Build Log

**Started:** <date>
**Status:** In progress | Blocked | Complete
**Parent:** [[05b - Hands-On Projects (Azure)]]
**Repo:** <github url once created>

## Summary
<one-paragraph elevator pitch — keep this current as scope evolves>

## Architecture (current state)
<mermaid diagram or description — update when topology changes>

## Resources Deployed
<running list of every Azure resource that exists right now, with name, region, purpose, and cost tier. Remove rows when destroyed.>

## Build Timeline
### <date> — <session title>
- What we did (bullet list, specific)
- Commands run (the actual ones, not paraphrased)
- What worked
- What broke and how we fixed it
- Screenshots captured (filenames)
- Time spent
- Next session starts with: <one sentence>

(repeat per session, newest at the bottom)

## Decisions & Trade-offs
<running list — every meaningful choice made, why, and what we rejected. Examples: "chose azurerm over azapi for Sentinel because…", "used consumption-tier Logic App because…". This becomes the interview talking-points doc.>

## Errors & Lessons
<every non-trivial error, what it meant, and the fix. Future-you and interviewers love this section.>

## Open Questions / TODOs
- [ ] <stuff blocked or pending>

## Cost Tracking
| Date | Estimated spend so far | Notes |
|------|------------------------|-------|

## Final Story (drafted at the end)
<the LinkedIn-ready narrative — written last, edited throughout>
```

**When Claude Code updates the Obsidian note:**

1. **At the start of every session** — read the note first using `obsidian_get_file_contents` to know where we left off. Don't ask Hassan "where were we" — check the note.
2. **After every meaningful step** — append to the current session entry under "Build Timeline" using `obsidian_patch_content` (append to the relevant heading) or `obsidian_append_content`. Don't batch updates to the end of the session — write them as they happen so nothing gets lost.
3. **When a decision is made** — add a row to "Decisions & Trade-offs" immediately, with the reasoning. These are gold dust for interviews and easy to forget.
4. **When an error happens** — log it under "Errors & Lessons" with the exact error message, root cause, and fix. Don't sanitize — the messy ones are the most useful.
5. **When a resource is created or destroyed** — update "Resources Deployed" so it always reflects reality. This doubles as a teardown checklist if costs spike.
6. **At the end of every session** — update "Status", fill in "Next session starts with: …", and confirm the note is saved.

**Tone of the notes:** Write as if Hassan is taking them himself in first person — "Today I deployed the Log Analytics workspace…", "I hit an error where azurerm_sentinel_alert_rule_scheduled didn't accept…". This makes the note usable as-is for LinkedIn drafts and interview prep, no rewriting needed. It also forces specificity — generic notes ("set up Sentinel ✅") are useless; specific notes ("created LAW in westeurope, 30-day retention, onboarded to Sentinel via the azurerm_sentinel_log_analytics_workspace_onboarding resource") are interview ammunition.

**Do not** create a new Obsidian note for every session — it's one living document that grows over time. **Do not** delete old entries even when they become stale — the history of mistakes is the value.

If the Obsidian MCP server is unavailable in a session, tell Hassan immediately and append to `BUILD_LOG.md` in the local repo as a fallback, then sync to Obsidian when it comes back.

---

## Working Style — How Hassan Wants to Work With Claude Code

- **Step-by-step, not all-at-once.** Hassan is learning Sentinel, Logic Apps, KQL, and Terraform for the first time on this project. Don't dump 500 lines of HCL without walking through what each block does. Explain as you build.
- **Teach the "why" before the "how".** Every resource we create, Hassan should be able to defend in an interview. Before writing a Terraform resource block, explain in 2-3 sentences what it does and why it's the right choice. This isn't tutorial-style filler — it's interview prep baked into the build.
- **Portal first for the unfamiliar, code second.** For services Hassan has never seen (Defender plans, Sentinel onboarding, Logic Apps designer), do it in the portal first to understand the screens, then codify in Terraform. For things he already knows or that are mechanical, jump straight to HCL.
- **Screenshot prompts.** When something visually meaningful happens in the portal (Secure Score drop, finding appears, Logic App run succeeds, Teams notification arrives), remind Hassan to screenshot it with a suggested filename. These screenshots are 50% of the LinkedIn post.
- **Update BUILD_LOG.md as we go.** After each meaningful step, append 2-3 lines to BUILD_LOG.md: what we did, what surprised us, what we'd do differently. This file becomes the interview script.
- **Honest pushback.** If Hassan suggests something that's wrong, overengineered, or going to blow the budget, say so directly. No flattery, no hedging.
- **Errors are learning, not failures.** When `terraform plan/apply` or an `az` command fails, don't just fix it — explain what the error means, why it happened, and how to read it next time. Provider errors, state lock errors, and `azurerm` schema mismatches are all common — treat each one as a teaching moment.

## Hassan's Background (so you calibrate technical depth)

- Has Sentinel and KQL experience already (basic to intermediate — comfortable with `where`, `summarize`, basic joins, less so with parsing/regex)
- Studying for AZ-500
- **No prior experience** with: Logic Apps, Terraform / IaC, Defender for Cloud (beyond hearing about it), GitHub Actions, OIDC federation
- Comfortable in the terminal, knows Git basics
- Target roles: Azure Security Engineer, Cloud Security Engineer, SOC L2/L3

Calibrate: assume he understands SOC and detection concepts well, and explain Azure-platform-specific stuff (resource groups, RBAC scoping, ARM under the hood, Terraform/HCL syntax, the `azurerm` provider's quirks) more carefully.

## Interview Story Arc (keep this in mind for every decision)

The story Hassan needs to be able to tell at the end is:

> "I noticed most cloud security tooling is reactive — Defender for Cloud gives you a list and humans triage hundreds of findings. I wanted to close the loop. So I built a pipeline where Defender findings flow into Sentinel, a KQL rule detects new public storage accounts the moment they're created, and a Logic App auto-remediates them and posts to Teams. I went from 'finding exists' to 'finding fixed' in under 60 seconds, with zero human involvement for that class of misconfiguration. Secure Score went from X to Y over two weeks. I built it in the portal first to learn the services, then codified everything as Terraform modules so the whole environment can be redeployed in one command — and the same modules will plug straight into a GitHub Actions OIDC pipeline as a follow-up project."

Every step we take should be evaluable against: "does this strengthen that story?" If not, cut it.

## Out of Scope (don't get distracted)

- Multi-subscription / management group rollout (mention as production scale but don't build)
- Custom CSPM connector for AWS/GCP (Defender CSPM multi-cloud — too much for this project)
- Full SOAR — we're doing one playbook well, not ten halfway
- A Bicep version (Terraform only — pick a lane)
- Production-grade Key Vault, Private Endpoints, Front Door, etc. — keep infra minimal, security tooling is the focus

## Deliberate Misconfigurations (the lab scenarios)

We'll create these on purpose so Defender catches them and we can demo the pipeline:
1. Public storage account (`allowBlobPublicAccess = true`) — **this is the one the auto-remediation playbook handles**
2. NSG with 3389/22 open to 0.0.0.0/0
3. Storage account without secure transfer required
4. VM without disk encryption
5. SQL server without auditing enabled

Document each in BUILD_LOG.md before creating, so we can tell the "before/after Secure Score" story.

## Useful Commands (cheatsheet — expand as we go)

```bash
# Azure auth (Terraform uses the az CLI session by default)
az login
az account set --subscription "<sub-id>"
az account show     # confirm correct sub before any apply

# Terraform workflow
cd terraform/
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan       # always review before apply
terraform apply tfplan
terraform destroy                # cost protection — run when not building

# State file lives locally for now (gitignored). Stretch goal: move to
# an Azure Storage Account backend with state locking.
```

**Terraform hygiene rules (non-negotiable):**
- `terraform.tfvars` is gitignored — never commits subscription IDs or tenant IDs
- `.terraform/`, `*.tfstate`, `*.tfstate.backup`, `tfplan` all gitignored
- Pin the `azurerm` provider version in `versions.tf` — don't let it float
- Always `plan` before `apply`, always read the plan output

## Confirmed Decisions

- **Notification target:** Microsoft Teams
- **OS / shell:** macOS / zsh
- **Region:** `uaenorth`
- **Resource naming convention:** `<resource>-secops-prod` — production-grade naming, no "lab" suffix (this is real-world work)
  - Examples: `rg-secops-prod`, `law-secops-prod`, `logic-secops-remediation-prod`

## Open Questions / Decisions Pending

- [ ] Naming convention confirmed? Proposed: `<resource>-secops-prod` — waiting on Hassan's sign-off
