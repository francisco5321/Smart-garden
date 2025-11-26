# Smart Garden Backend

This is the backend service for the Smart Garden application. It provides a RESTful API to manage garden data, including creating, retrieving, updating, and deleting garden entries.

## Project Structure

```
smart-garden-backend
├── src
│   ├── index.ts               # Entry point of the application
│   ├── routes
│   │   └── api.ts             # API routes definition
│   ├── controllers
│   │   └── gardenController.ts # Controller for garden-related operations
│   ├── models
│   │   └── gardenModel.ts      # Data model for the garden
│   ├── services
│   │   └── gardenService.ts     # Business logic for garden operations
│   └── middleware
│       └── auth.ts             # Authentication middleware
├── package.json                # NPM configuration file
├── tsconfig.json               # TypeScript configuration file
└── README.md                   # Project documentation
```

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd smart-garden-backend
   ```

3. Install the dependencies:
   ```
   npm install
   ```

## Usage

To start the server, run:
```
npm start
```

The server will be running on `http://localhost:3000` by default.

## API Endpoints

The following endpoints are available:

- `GET /api/gardens` - Retrieve all gardens
- `POST /api/gardens` - Create a new garden
- `GET /api/gardens/:id` - Retrieve a specific garden by ID
- `PUT /api/gardens/:id` - Update a specific garden by ID
- `DELETE /api/gardens/:id` - Delete a specific garden by ID

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License.