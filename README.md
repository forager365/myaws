# DynamoDB Manager

A comprehensive web application for managing AWS DynamoDB tables with full CRUD operations and an intuitive interface.

## Features

- **Dashboard**: Overview of all tables with statistics
- **Table Management**: View, create, edit, and delete items across multiple table types
- **Sample Data**: Pre-configured with AWS DynamoDB sample tables (ProductCatalog, Forum, Thread, Reply)
- **Responsive Design**: Built with Tailwind CSS for optimal viewing on all devices
- **TypeScript**: Full type safety throughout the application
- **Real-time Operations**: Live updates when performing CRUD operations

## Table Structure

The application manages the following DynamoDB tables as specified in the AWS documentation:

### ProductCatalog
- **Primary Key**: Id (Number)
- **Use Case**: Product inventory management
- **Sample Data**: Books and bicycles with various attributes

### Forum
- **Primary Key**: Name (String)
- **Use Case**: Discussion forum management
- **Sample Data**: AWS service forums

### Thread
- **Primary Key**: ForumName (String) + Subject (String)
- **Use Case**: Forum thread management
- **Sample Data**: Discussion threads with metadata

### Reply
- **Primary Key**: Id (String) + ReplyDateTime (String)
- **Global Secondary Index**: PostedBy-Message-Index
- **Use Case**: Thread reply management
- **Sample Data**: User replies to forum threads

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React App     │    │   Express API   │    │   DynamoDB      │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   Tables        │
│                 │    │                 │    │                 │
│ - Dashboard     │    │ - CRUD APIs     │    │ - ProductCatalog│
│ - Table Views   │    │ - Query APIs    │    │ - Forum         │
│ - Item Forms    │    │ - Health Check  │    │ - Thread        │
│ - Navigation    │    │ - Error Handling│    │ - Reply         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- AWS Account with DynamoDB access
- AWS CLI configured (optional, for local development)

## Installation

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your AWS credentials and configuration
```

4. Create DynamoDB tables:
```bash
npm run create-tables
```

5. Seed sample data:
```bash
npm run seed-data
```

6. Start the development server:
```bash
npm run dev
```

The backend will be available at `http://localhost:3001`

### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your API URL and configuration
```

4. Start the development server:
```bash
npm start
```

The frontend will be available at `http://localhost:3000`

## Environment Configuration

### Backend (.env)
```bash
# AWS Configuration
AWS_REGION=us-west-2
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key

# For local DynamoDB development
# DYNAMODB_ENDPOINT=http://localhost:8000

# Server Configuration
PORT=3001
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
```

### Frontend (.env)
```bash
# API Configuration
REACT_APP_API_URL=http://localhost:3001/api

# Feature flags
REACT_APP_ENABLE_DEBUG=true
REACT_APP_ENABLE_MOCK_DATA=false
```

## Development with Local DynamoDB

For local development, you can use DynamoDB Local:

1. Download and run DynamoDB Local:
```bash
# Download DynamoDB Local
wget https://s3.us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz
tar -xzf dynamodb_local_latest.tar.gz

# Run DynamoDB Local
java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb
```

2. Update your backend `.env` file:
```bash
DYNAMODB_ENDPOINT=http://localhost:8000
```

## API Endpoints

### Generic CRUD Operations
- `GET /api/tables/:table` - Get all items from a table
- `POST /api/tables/:table/get` - Get a specific item by key
- `POST /api/tables/:table` - Create a new item
- `PUT /api/tables/:table` - Update an existing item
- `DELETE /api/tables/:table` - Delete an item

### Specialized Queries
- `GET /api/forums/:forumName/threads` - Get threads by forum
- `GET /api/threads/:threadId/replies` - Get replies by thread
- `GET /api/users/:username/replies` - Get replies by user

### Health Check
- `GET /api/health` - Service health status

## Usage

### Dashboard
- View overview of all tables
- See item counts and table statistics
- Navigate to specific table views

### Table Management
1. **View Items**: Browse all items in a table with search functionality
2. **Create Items**: Add new items with form validation
3. **Edit Items**: Modify existing items with pre-populated forms
4. **Delete Items**: Remove items with confirmation prompts

### Search and Filter
- Real-time search across all item fields
- Responsive table views with pagination support
- Mobile-optimized interface

## Production Deployment

### Backend Deployment
1. Build the application:
```bash
npm run build
```

2. Set production environment variables
3. Deploy to your preferred platform (AWS ECS, Heroku, etc.)

### Frontend Deployment
1. Build the application:
```bash
npm run build
```

2. Deploy the `build` folder to your web server or CDN

### AWS Deployment Recommendations
- **Backend**: AWS ECS with Application Load Balancer
- **Frontend**: AWS S3 + CloudFront
- **Database**: AWS DynamoDB (production tables)
- **Monitoring**: AWS CloudWatch for logging and metrics

## Security Considerations

- Use IAM roles and policies for DynamoDB access
- Implement API authentication and authorization
- Enable CORS only for trusted domains
- Use HTTPS in production
- Validate all input data
- Implement rate limiting

## Troubleshooting

### Common Issues

1. **Connection to DynamoDB fails**
   - Verify AWS credentials
   - Check IAM permissions
   - Ensure correct region configuration

2. **Tables not found**
   - Run the table creation script
   - Verify table names match configuration

3. **API requests fail**
   - Check backend server is running
   - Verify CORS configuration
   - Check network connectivity

### Debug Mode
Enable debug logging by setting:
```bash
REACT_APP_ENABLE_DEBUG=true
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Open an issue on GitHub
- Check the troubleshooting section
- Review AWS DynamoDB documentation