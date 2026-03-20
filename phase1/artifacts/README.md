# DevOps Product Web App

A simple web application built for the mid-term project of **Software Deployment, Operations and Maintenance**. The system provides a working web interface, a database-backed product management module, and a backend file upload feature. It is designed to support both traditional host-based deployment and containerized deployment.

## Features

- Server-rendered web interface using EJS
- REST API for product management
- MongoDB integration with Mongoose
- Automatic fallback to in-memory storage when MongoDB is unavailable
- File upload support using Multer
- Static file serving for uploaded images

## Technology Stack

- Node.js
- Express.js
- EJS
- MongoDB
- Mongoose
- Multer

## Project Structure

```text
controllers/        Request handling logic
models/             Mongoose data models
routes/             API and UI routes
services/           Data access abstraction layer
validators/         Request validation
views/              EJS templates
public/             Static assets
scripts/            Automation scripts for server preparation
phase1/             Artefacts and evidence for Phase 1
phase2/             Artefacts and evidence for Phase 2
phase3/             Artefacts and evidence for Phase 3
main.js             Application entry point