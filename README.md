# PostgreSQL Docker Image with pg_roaringbitmap

This repository provides a PostgreSQL Docker image with the `pg_roaringbitmap` extension pre-installed. The image is built using GitHub Actions and pushed to GitHub Container Registry (GHCR).

## Features

- PostgreSQL with configurable version (13, 14, 15, 16, 17)
- Pre-installed `pg_roaringbitmap` extension
- Multi-platform support (linux/amd64, linux/arm64)
- Automatic builds via GitHub Actions
- Images hosted on GitHub Container Registry (GHCR)

## Available Tags

- `ghcr.io/your-username/postgres-roaringbitmap:13` - PostgreSQL 13 with pg_roaringbitmap
- `ghcr.io/your-username/postgres-roaringbitmap:14` - PostgreSQL 14 with pg_roaringbitmap
- `ghcr.io/your-username/postgres-roaringbitmap:15` - PostgreSQL 15 with pg_roaringbitmap
- `ghcr.io/your-username/postgres-roaringbitmap:16` - PostgreSQL 16 with pg_roaringbitmap
- `ghcr.io/your-username/postgres-roaringbitmap:17` - PostgreSQL 17 with pg_roaringbitmap
- `ghcr.io/your-username/postgres-roaringbitmap:latest` - Latest stable version (PostgreSQL 15)

## Quick Start

### Using Docker

```bash
# Run PostgreSQL with pg_roaringbitmap
docker run -d \
  --name postgres-roaringbitmap \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  ghcr.io/your-username/postgres-roaringbitmap:15
```

### Using Docker Compose

```yaml
version: '3.8'
services:
  postgres:
    image: ghcr.io/your-username/postgres-roaringbitmap:15
    environment:
      POSTGRES_PASSWORD: mysecretpassword
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## Using pg_roaringbitmap Extension

Once connected to the database, you can enable and use the extension:

```sql
-- Enable the extension
CREATE EXTENSION roaringbitmap;

-- Check extension version
SELECT roaringbitmap_version();

-- Example usage
CREATE TABLE example (
    id SERIAL PRIMARY KEY,
    bitmap ROARINGBITMAP
);

-- Insert data
INSERT INTO example (bitmap) VALUES (rb_build('{1,2,3,4,5}'::integer[]));

-- Query data
SELECT rb_cardinality(bitmap) FROM example;
```

## Building Locally

### Prerequisites

- Docker
- Bash shell

### Build Script

Use the provided build script to build images locally:

```bash
# Build with default PostgreSQL version (15)
./build.sh

# Build with specific PostgreSQL version
./build.sh 16

# Build with custom image name
./build.sh 15 ghcr.io/your-username/postgres-custom

# Show help
./build.sh --help
```

### Manual Build

```bash
# Build with build-arg
docker build \
  --build-arg POSTGRES_VERSION=15 \
  -t postgres-roaringbitmap:15 \
  .

# Run the built image
docker run -d \
  --name postgres-test \
  -e POSTGRES_PASSWORD=testpassword \
  -p 5432:5432 \
  postgres-roaringbitmap:15
```

## GitHub Actions

This repository uses GitHub Actions to automatically build and push images to GHCR. The workflow is triggered by:

1. **Manual dispatch**: You can manually trigger builds and select PostgreSQL version
2. **Push to main/master**: Automatically builds PostgreSQL 15 version
3. **Pull requests**: Builds but doesn't push images

### Manual Build via GitHub Actions

1. Go to the Actions tab in your repository
2. Select "Build and Push Docker Image" workflow
3. Click "Run workflow"
4. Select the desired PostgreSQL version
5. Click "Run workflow"

The workflow will:
- Build the Docker image for both amd64 and arm64 architectures
- Push to GHCR (except for pull requests)
- Test the built image to ensure the extension works correctly

## Configuration

### Environment Variables

The image accepts all standard PostgreSQL environment variables:

- `POSTGRES_PASSWORD` (required)
- `POSTGRES_USER` (default: postgres)
- `POSTGRES_DB` (default: same as POSTGRES_USER)
- `POSTGRES_INITDB_ARGS`
- `POSTGRES_INITDB_WALDIR`

### Volumes

- `/var/lib/postgresql/data` - PostgreSQL data directory

### Ports

- `5432` - PostgreSQL default port

## Support

For issues related to:
- **This Docker image**: Please open an issue in this repository
- **pg_roaringbitmap extension**: Please refer to the [pg_roaringbitmap repository](https://github.com/ChenHuajun/pg_roaringbitmap)
- **PostgreSQL**: Please refer to the [PostgreSQL documentation](https://www.postgresql.org/docs/)

## License

This project is licensed under the same license as PostgreSQL. The pg_roaringbitmap extension has its own license - please refer to its repository for details.