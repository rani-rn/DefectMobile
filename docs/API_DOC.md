END-POINT API


# Authentication
POST /api/apiauth/register
Description: Register a new user
Request Body: 
{
  "name": "Full Name",
  "email": "user@example.com",
  "password": "password123",
  "confirmPassword": "password123",
  "role": "Admin" // or "QC"
}
Response: 
200 OK - registration success
400 Bad Request - Email already exists or passwords do not match


POST /api/apiauth/login
Description: Authenticate a user and return a JWT token
Request Body:
{
  "email": "user@example.com",
  "password": "password123"
}
Response: 
{
  "token": "JWT_TOKEN",
  "user": {
    "id": 1,
    "name": "Full Name",
    "email": "user@example.com",
    "role": "Admin"
  }
}
or 401 Unauthorized - Invalid credentials

# Profile 
All endpoints below require the following HTTP header:
Authorization: Bearer JWT_TOKEN

GET /api/apiprofile/profile
Description: Get the user's profile information
Response:
{
  "name": "Full Name",
  "email": "user@example.com",
  "role": "Admin"
}

POST /api/apiprofile/change-password
Description: Change the user's password
Request Body:
{
  "currentPassword": "oldPassword",
  "newPassword": "newPassword"
}
Response:
- 200 OK - Password Update Successfully
- 400 Bad Request - Current Password is incorrect

# Defect Management
GET /api/defect/chart
Description: Get the defect chart data based on the se;ected time period (daily, weekly, monhtly, annual)
Query Parameters:
- defectId 
- timePeriod
Response:
{
  "chartData": [
    {
      "label": "Line Production A",
      "value": 10
    }
  ],
  "total": 50,
  "daily": 5,
  "weekly": 20,
  "monthly": 35,
  "annual": 50
}

GET /api/defect/all
Description: Fetch all defect reports
Response: Array of defect reports with model, section, line production, and defect details

GET /api/defect/{id}
Description: Fetch a defect report by id
Response:Detailed object of the selected defect report.

POST /api/defect/add-defect
Description: Add a new defect type
Request Body:
{
  "defectName": "Defect Name"
}
Response: 
200 OK - Defect Added successfully or already exists

POST /api/defect/add-report
Description: Add a new defect report
Request Body:
{
  "reportDate": "2025-05-20T00:00:00",
  "reporter": "Reporter Name",
  "lineProdQty": 100,
  "defectQty": 5,
  "description": "Optional description",
  "defectId": 1,
  "lineProductionId": 2,
  "sectionId": 3,
  "modelId": 4
}
Response:
200 OK - Report Added successfully

PUT /api/defect/update/{id}
Description: Update a defect report by id
Request Body: same as add-report body
Response:
- 200 OK - Resport updated successfully
- 400 Bad request - ID mismatch or validation error
- 404 not found - Report not found

DELETE /api/defect/delete/{id}
Description: Delete a defect report by id
Response:
- 200 OK -report deleted
- 404 not found - Report Not Found

GET /api/defect/dropdown
Description: Fetch all defect types, line production , sections, and models for dropdown
Response:
{
  "sections": [...],
  "defects": [...],
  "lineProductions": [...],
  "models": [...]
}
