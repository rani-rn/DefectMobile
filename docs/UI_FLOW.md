# 🧭 Overview
This documentation describes the user interface flow of the Defect Record web and mobile apps, including navigation, user actions, and connections to API endpoints. It is designed to guide users and developers through the overall logic and interaction patterns.
📱 Note for Mobile Version:
- Export to Excel is not available on mobile.
- Date filtering on the Defect Report List Page is limited to ascending/descending sort, unlike the full date range picker available on the web version.

# 📝 Register Page
Function: Allows new users to create an account in the system.

UI Elements:
- Name Field
- Email Field
- Role
- Password Field
- Confirm Password Field
- Register Button
- Link to Login Page

Behavior:
- On clicking Register, the form sends a POST request to /api/apiauth/register.
- If the registration is successful:A success message is shown (e.g., "Account created successfully.").
- User may be redirected to the login page or automatically logged in.
- If registration fails (e.g., email already used, password mismatch, or validation error):
- An error message is displayed under the related field or as a general alert.

# 🔐 Login Page
Function: Authenticate users to access the system
UI Elements:
- email fields
- password fields
- login button
- link to register
Behavior:
- On clicking Login, the form sends a POST request to /api/apiauth/login
- If the credentials are valid, the user is redirected to the dashboard page
- If the credentials are invalid, an error message is displayed

# 🏠 Dashboard Page
Function: Overview of defect data via summary boxes and a bar chart
UI Elements:
- Summary boxes: Total, Daily, Weekly, Monthly, Annual
- Filter Dropdowns: Time Period (daily, weekly, etc), Defect Type
- Bar Chart: Displays defect distribution by line
- Navigation Sidebar
Behavior:
- Fetches chart data from GET /api/defect/chart
- Dropdown  changes trigger chart data reload via query parameters
- Sidebar navigation links to other pages

# ➕ Input Defect Report Page
Function: Submit a new defect reports
UI Elements:
- Form Fields:
    - Reporter
    - Report Date
    - Model (dropdown)
    - Section (dropdown)
    - Line Production (dropdown)
    - Line Production Qty 
    - Defect Item (dropdown)
    - Description (optional)
    - Defect Quantity
- Save Button
- Cancel Button
Behavior:
- Dropdowns are populated using GET /api/defect/dropdown
- On submit:
    - The system checks if the selected defect exists in the Defect Table. If the defect does not exist, it sends a POST request to /api/defect/add-defect to create a new defect entry first. After ensuring the defect exists, the system sends a POST request to /api/defect/add-report with the report details.
- On success, A success message is displayed and the form is cleared or the user is redirected to the defect report history.

# 📄 Defect Report List Page
Function: Displays a list of defect reports
UI Elements:
- Table: Displays rows of defect reports
- Filtered Date for table
- Search
- Pagination
- Export to Excel button
- Action button (edit, delete)
Behavior:
- Fetches table data from GET /api/defect/all
- Filtered date and search trigger table data reload via query parameters
- Clicking "Edit" navigates to /api/defect/update/{id}
- Clicking "Delete" calls DELETE /api/defect/delete/{id} with sweetalert confirmation

# ✏️ Edit Defect Report Page
Function: Edit an existing defect report
UI Elements:
- Same form as Add Report, prefilled with existing data.
Behavior:
- Fetch data using GET /api/defect/{id}.
- On submit, sends PUT /api/defect/update/{id}. There is also checking for new defect like Input Defect Page

# 👤 User Profile Page
Function: Display user info and allow password change.

UI Elements:
- User Info Display
- Password Change Form:
    - Current Password
    - New Password
    - Confirm New Password

Behavior:
- User data fetched via GET /api/apiprofile/profile.
- Password change uses POST /api/apiprofile/change-password.

# 🚪 Logout Functionality
Function: Logs out the user and redirects to login page.
Trigger: Button in header or sidebar
Behavior:
- Clears JWT token from local storage/session.
- Redirects to /login.