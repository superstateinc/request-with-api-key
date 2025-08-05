# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.4] - 2025-08-04

### Added
- Initial Elixir port of the TypeScript `@superstateinc/api-key-request` package
- `SuperstateApiKeyRequest.request/1` function for making authenticated API requests
- HMAC-based authentication with proper header signing
- Support for GET, POST, PUT, DELETE HTTP methods
- Query parameter and request body handling
- `SuperstateApiKeyRequest.Types` module with type definitions
- `SuperstateApiKeyRequest.Example` module with usage examples
- Comprehensive test suite
- Documentation with ExDoc support
- Hex.pm publishing configuration

### Features
- Environment variable support for API credentials
- Configurable base URL
- Automatic query parameter sorting and hashing
- Request body sorting and hashing
- Error handling for HTTP requests and JSON parsing
- Transaction status enum support

### Dependencies
- Jason ~> 1.4 for JSON encoding/decoding
- HTTPoison ~> 2.0 for HTTP requests
- ExDoc ~> 0.27 for documentation generation

### Documentation
- Complete README with usage examples
- Inline documentation for all public functions
- Type specifications using Elixir typespecs
- Example usage patterns