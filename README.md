# CoinMarketCapApplication
Recreation of the popular CoinMarketCap Application using Flutter for the frontend and C#.NET for the backend. 

## Requirements for Setup

To successfully run this project, you'll need the following tools and software installed on your machine:

### 1. Microsoft SQL Server
- Install **Microsoft SQL Server** (SQL Server 2019 or later recommended).
- Optionally, install **SQL Server Management Studio (SSMS)** to manage the database.

#### SQL Server Setup:
- During installation, configure the server with **Mixed Mode Authentication**.
- Set up a SQL Server instance and ensure it is running.

#### Database Setup:
- Create a new database for the project in SQL Server.
- Create a CryptoCurrencies table that matches the structure used in the C# backend.

### 2. .NET Core SDK
- Install the **.NET Core SDK** (version 6.0 or later).
- You can download the SDK from the official .NET website: [Download .NET Core SDK](https://dotnet.microsoft.com/download).

### 3. Flutter
- Install **Flutter** for the frontend development. Follow the installation instructions here: [Install Flutter](https://flutter.dev/docs/get-started/install).
- Set up **Android Studio** or **Visual Studio Code** with the required plugins to run Flutter apps.

### 4. Database Configuration
- In the backend project (C#.NET), update the `appsettings.json` file with the correct connection string to connect to your SQL Server instance. For example:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=YourDatabase;User Id=YourUsername;Password=YourPassword;"
}
```

### 5. Database Configuration
#### Backend
- Navigate to the backend project directory and run the following command:
 ```dotnet run```
#### Frontend
- Navigate to the Flutter project directory and run the following command:
```flutter run``` or ```f5 on VScode```

