# 🚀 Post-Installation Configuration Guide — Cloutik

> **Guide Version:** 1.1
> **Estimated Time:** 15-20 min
> **Required Level:** System Administrator

Congratulations! Your **Cloutik** instance is successfully installed.
This guide will walk you through the steps to transform this raw installation into a secure, functional, and fully branded production platform.

---

## 🎨 1. Visual Customization (White Label)

Adapt the interface to your brand identity by modifying the logos and background.

**Path:** `Management` > `Parameters`

In the parameters list, locate and edit the following fields (click "Edit"):

### A. Instance Logos
* **Instance Logo** (Key: `clk_logo`)
    * *Description:* The main logo visible at the top of the interface once logged in.
    * *Recommended Format:* Transparent PNG, approx. `250x70px`.

* **Instance login page Logo** (Key: `clk_login_logo`)
    * *Description:* The logo that appears above the login form.
    * *Tip:* Can be a larger or square version of your logo.

### B. Background
* **Register/Login Page image** (Key: `clk_background`)
    * *Description:* The large background image for the login and registration pages.
    * *Recommended Format:* High resolution (`1920x1080px`) to avoid pixelation on large screens.

---

## 🔐 2. Securing the Instance (2FA)

To protect access to your administrator account, it is mandatory to enable Two Factor Authentication.

**Path:** Top right menu (Avatar) > `Profile`

Scroll down to the **Two Factor Authentication** section. You will see the status: *You have not enabled two factor authentication*.

Two activation methods are available (click the **Enable** button corresponding to your choice):

### Option A: Google Authenticator (Mobile App)
Generate a secure token via your phone.
* Look for the line: *You may retrieve this token from your phone's Google Authenticator application*.
* Click **Enable**.

### Option B: Email Address
Receive the login token by email at each authentication.
* Look for the line: *Or You may retrieve this token from your email address*.
* Click **Enable**.

---

## 📧 3. SMTP Configuration (Emails & Notifications)

Correct configuration is essential for security (2FA, password reset) and for monitoring your equipment.
In Cloutik, configuration is done in **two distinct steps**.

**Path:** `Management` > `Parameters`

### A. System Emails (Email Setting)
This section handles critical sends: 2FA codes, password recovery, licenses, and support. Search for the **Email Setting** section and configure the following keys:

| Parameter (Key) | Description / Recommended Value |
| :--- | :--- |
| **Email account username**<br>`mailusername` | Your sending address (e.g., `noreply@your-domain.com`) |
| **Email account password**<br>`mailpassword` | The email account password |
| **Email Field From**<br>`mailfrom` | Display name + email (e.g., `Cloutik <noreply@your-domain.com>`) |
| **Email SMTP Gateway**<br>`mailserver` | SMTP Server (e.g., `ssl0.ovh.net`) |
| **Email SMTP Secure**<br>`mailsmtpsecure` | Encryption protocol (`ssl` or `tls`) |
| **Email SMTP Port**<br>`mailport` | Port (`465` for SSL, `587` for TLS) |
| **Email Licenses Sender**<br>`maillicense` | Specific address for sending licenses |
| **Email Support Sender**<br>`mailsupport` | Address used for support exchanges |

> **✅ Required Action:** Click **"Update and test email parameters"** to validate this part.

---

### B. Notification Emails (Notifications)
This section handles monitoring alerts. Search for the **Notifications** section.

**1. Activation**
* **Enable Notifications** (`clk_instance_notifications`): Set the value to `yes` to enable the alert system.

**2. Configuration**
Fill in the following parameters for the account that will send alerts:

* **Notification Email account** (`clk_ntmail`): Sending account.
* **Notification Email password** (`clk_ntpwd`): Password.
* **Notification Email Field From** (`clk_ntmailfrom`): Sender (e.g., `Cloutik Alert <alert@your-domain.com>`).
* **Notification SMTP Gateway** (`clk_ntsmtp`): SMTP Server.
* **Email STMP Secure** (`clk_mailsmtpsecure`): Encryption (`ssl` or `tls`).
* **Notification SMTP Port** (`clk_ntsmtppt`): SMTP Port.
* **Monitoring Mail** (`clk_monitoring_mail`): Alert reception address.

> **✅ Required Action:** Click **"Update and test notification parameters"** to verify that you receive the test aler.

---

## 🌍 4. Connecting the First Router (Adoption)

To add a device, you must navigate to the **Adoption Page**. Cloutik offers 3 methods to connect a MikroTik router.

**Path:** `Devices` > `Adopt` (or `/device/adopt`)

Choose the method that suits your workflow:

### A. Using the Terminal (Fastest)
1.  Select the **"Using the Terminal"** tab.
2.  Copy the command line displayed on the screen.
3.  Open a **New Terminal** in your MikroTik (Winbox).
4.  Paste the command and press **Enter**.

> **⚠️ Cloud Hosted Router (CHR):** If you are using a virtual router (CHR), select the specific **"Using the Terminal CHR"** tab. CHRs do not have a hardware serial number, so the system will ask you to generate a unique ID.

### B. Add Script Method (Persistent)
1.  In your MikroTik, go to `System` > `Scripts`.
2.  Create a new script named **Init**.
3.  Copy the content from the "Add Script" tab in Cloutik into the **Source** field.
4.  Click **"Run Script"**. The device will automatically associate with your account.

### C. Using the RSC File (Offline/File based)
1.  Download the generated `.rsc` file from the Cloutik interface.
2.  Upload this file to your MikroTik's **Files** directory.
3.  Open a terminal and execute: `/import Cloutik.rsc`

---

## 👤 5. User & License Management

Manage your administrative accounts and their rights.

### A. Default Super Admin & Free License
During the initial installation (`install.sh`), a **Super Admin** account was automatically created using the information you provided.
By default, this account is assigned a **Free License** limited to **2 devices**.

### B. Modifying the License
If you wish to upgrade this user's plan:
1.  Go to `Licenses` > `Accounts`.
2.  Click the **Edit** button on the user row.
3.  Select a new license from the list (pulled from your License Catalog).
4.  Click **Save**.

### C. Creating New Users
You can create as many users as needed (for your team or clients):
1.  Go to `Licenses` > `Accounts` > `ADD`.
* Assign them a specific license from your catalog during creation.

> **💡 Note:** You can also customize your license offers (device limits) by going to `Administration` > `License Catalog`.

---