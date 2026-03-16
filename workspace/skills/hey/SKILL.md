---
name: hey
description: "Interact with HEY email using browser automation. Check The Screener, manage Imbox, and handle email screening autonomously."
metadata: {"nanobot":{"emoji":"📧","requires":{"bins":["agent-browser"]},"install":[]}}
---

# HEY Email Skill

Manage HEY email using browser automation. HEY has a unique email workflow with The Screener, Imbox, and Paper Trail.

## HEY Concepts

### The Screener
- **What it is:** First line of defense - all new senders go here
- **Your job:** Decide "yay" (let into Imbox) or "nay" (reject/spam)
- **Why it matters:** You only see emails from people you've approved

### Imbox
- **What it is:** Important box - only screened-in emails appear here
- **What goes here:** Emails you want to see, replies to your emails
- **Check frequency:** Multiple times per day

### Paper Trail
- **What it is:** Receipts, notifications, automated emails
- **What goes here:** Transactional emails, newsletters you've screened in
- **Check frequency:** Once per day or less

### Spam
- **What it is:** Rejected emails from The Screener
- **Auto-delete:** After 30 days

## Prerequisites

- Credentials in MEMORY.md under "HEY Account Credentials"
- Browser tool enabled
- Use `browser` tool for all HEY operations

## Authentication

HEY keeps you logged in via cookies. If logged out:
1. Navigate to https://app.hey.com
2. Log in with credentials from MEMORY.md:
   - Email: danubot@hey.com
   - Password: [from MEMORY.md]
3. Handle 2FA if prompted (OTP secret in MEMORY.md)

## Autonomous Workflows

### 1. Check The Screener

**When user says:** "Check my screener" / "Screen my emails" / "What's in The Screener?"

**Workflow:**
1. Open HEY: `browser open https://app.hey.com`
2. Take screenshot to see current state
3. If on login page, authenticate with credentials from MEMORY.md
4. Navigate to The Screener (usually default view or click "Screener")
5. Take screenshot to see emails waiting
6. For each email in screener:
   - Read sender name and subject
   - Check sender against MEMORY.md "HEY Email Auto-Response Rules"
   - **Auto-approve if:**
     - Sender is in MEMORY.md allowed list (emmanuel@hey.com, danieleangeli@hey.com)
     - Known contact from previous interactions
   - **Auto-reject if:**
     - Obvious spam patterns (fake invoices, phishing, suspicious links)
     - Marketing from unknown companies
     - Unsolicited bulk email
   - **Ask user if:**
     - Unsure about sender
     - Potentially important but unknown
     - Mixed signals (legitimate domain but spammy content)

**Example decision flow:**
```
Email from: "shipping@amazon.com" Subject: "Your order has shipped"
→ Auto-approve (known sender, transactional)

Email from: "winner@prizes-now.xyz" Subject: "You won $1,000,000!"
→ Auto-reject (spam pattern)

Email from: "john.smith@gmail.com" Subject: "Project collaboration"
→ Ask user: "Email from john.smith@gmail.com about 'Project collaboration' - approve or reject?"
```

### 2. Check Imbox

**When user says:** "Check my email" / "What's in my inbox" / "Any important emails?"

**Workflow:**
1. Open HEY: `browser open https://app.hey.com`
2. Log in if needed
3. Click "Imbox" tab
4. Take screenshot
5. Report:
   - Number of unread emails
   - Sender and subject of each
   - Flag any emails that seem urgent

### 3. Auto-Screen Based on Rules

**When user says:** "Auto-screen my emails" / "Process my screener"

**Workflow:**
1. Check The Screener (workflow #1)
2. Apply auto-rules from MEMORY.md
3. **CONFIRM BEFORE BULK ACTIONS:**
   ```
   "I found 5 emails in The Screener:
   - Approve: 2 (known senders)
   - Reject: 2 (spam)
   - Unclear: 1 (need your input)
   
   I'll approve the 2 known senders and reject the 2 spam emails.
   For the unclear one, I'll wait for your input.
   
   Proceed? (yes/no)"
   ```
4. Execute approved actions
5. Report results

### 4. Reply to Important Emails

**When user says:** "Reply to emails from X" / "Respond to Y about Z"

**Workflow:**
1. Open HEY
2. Find email in Imbox (use search or scroll)
3. Open email
4. Click Reply
5. Compose response
6. **CONFIRM BEFORE SENDING:**
   ```
   "Here's my draft reply:
   [draft text]
   
   Send this email? (yes/no)"
   ```

## Auto-Response Rules (from MEMORY.md)

**Always Approve:**
- emmanuel@hey.com
- danieleangeli@hey.com
- Any email where you're CC'd on a thread
- Replies to your sent emails

**Always Reject (Spam Patterns):**
- Lottery/prize winnings
- Fake invoices (PDF attachments from unknown senders)
- Phishing attempts (suspicious links)
- Adult content
- Cryptocurrency scams
- Urgent messages with poor grammar

**Ask User:**
- Unknown personal email addresses
- Vague subject lines from unknown senders
- Business proposals
- Collaboration requests

## Confirmation Requirements

**ALWAYS ask for confirmation before:**
- Rejecting emails (moving to spam)
- Sending replies
- Bulk screening actions (approving/rejecting multiple at once)

**Format:**
```
"I'm about to reject 3 emails as spam:
1. winner@scam.com - "You won!"
2. invoice@fake-paypal.com - "Invoice #12345"
3. prince@nigeria.com - "Business proposal"

These will go to spam and be deleted after 30 days.

Confirm? (yes/no)"
```

## Browser Workflow

**Navigation:**
1. `browser open https://app.hey.com`
2. `browser wait 2000` (wait for page load)
3. `browser snapshot -i` (see interactive elements)
4. If login form visible: fill credentials
5. `browser click "Screener"` or navigate to desired section
6. `browser screenshot` (capture state)

**Screening:**
1. `browser click "Yay"` (approve) or `browser click "Nay"` (reject)
2. `browser wait 500` (wait for animation)
3. Repeat for each email

## Error Handling

If login fails:
1. Check credentials in MEMORY.md
2. Try again
3. If 2FA required, use OTP secret from MEMORY.md
4. Report: "Login failed, please verify credentials"

If page doesn't load:
1. Check internet connection
2. Try refreshing: `browser open https://app.hey.com`
3. Report if still failing

## Examples

**User:** "Check my screener"
**Agent:** *[Opens HEY, checks screener]*
"You have 3 emails in The Screener:
1. amazon.com - "Your order shipped" → Auto-approving (known sender)
2. winner@xyz.com - "You won!" → Auto-rejecting (spam)
3. john@gmail.com - "Meeting tomorrow?" → This looks legitimate but I don't recognize the sender. Approve or reject?"

**User:** "approve"
**Agent:** *[Approves john@gmail.com]*
"Done! Approved 2 emails, rejected 1 spam. Your Imbox now has the 2 approved emails."

**User:** "Check my email"
**Agent:** *[Checks Imbox]*
"You have 2 unread emails in Imbox:
1. From: emmanuel@hey.com - "Project update"
2. From: danieleangeli@hey.com - "Meeting notes"

Both from your allowed senders list."
