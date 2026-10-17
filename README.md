# Manohar Gollapudi Portfolio

A dark-first, responsive portfolio for DevOps and cloud infrastructure work. The public site is built with React, Vite, Tailwind CSS, Lucide icons, and Supabase. Supabase stores portfolio content, messages, credentials, projects, war stories, and learning entries.

## What is included

- Resume-based experience, skills, certifications, education, and projects
- Filterable projects and skills
- Interactive project responsibilities and expandable war stories
- Light and dark themes
- Responsive layout with reduced-motion support
- Downloadable resume action
- Protected owner editor for profile updates, draft creation, and removal
- Contact form backed by Supabase
- Docker and Compose files
- ARM64-compatible Helm deployment template
- GitHub Actions quality checks and multi-architecture image publishing

## Local use

1. Open the project in Bolt. Supabase is already provisioned for this project.
2. The app starts automatically in Bolt.
3. Open the private editor from the `Editor` button in the header.
4. Sign in with the owner account to edit the introduction or add/remove content.
5. Use the theme button in the header to switch between dark and light modes.

The resume is available from the hero button. Certification issue dates, credential IDs, and verification links are intentionally blank because they were not present in the supplied resume; they can be added through the editor when available.

## One setting to switch on yourself

Only the owner account is allowed into the editor, and the editor now checks that before it opens. To stop strangers from creating accounts on the project at all, open your Supabase dashboard, go to Authentication → Sign In / Providers, and turn off new user sign-ups for the email provider. Your own account keeps working.

## Docker

Build and run the production image with:

```bash
docker compose up --build
```

Then open `http://localhost:8080`. The container serves the compiled static site through Nginx and includes a `/healthz` health endpoint.

Your local settings file is deliberately excluded from the image build, so the two public Supabase values are passed in as build arguments. Compose picks them up from your shell:

```bash
export $(grep -v '^#' .env | xargs)
docker compose up --build
```

If you build the image directly, pass them yourself:

```bash
docker build \
  --build-arg VITE_SUPABASE_URL="$VITE_SUPABASE_URL" \
  --build-arg VITE_SUPABASE_ANON_KEY="$VITE_SUPABASE_ANON_KEY" \
  -t portfolio:local .
```

## Kubernetes with Helm

1. Build and publish a multi-architecture image using the included GitHub Actions workflow, or build one locally for your cluster.
2. Update `helm/portfolio/values.yaml` with the image repository, hostname, and public Supabase values.
3. Install the chart:

```bash
helm upgrade --install manohar-portfolio ./helm/portfolio
```

The chart includes a Deployment, Service, health probes, resource requests and limits, optional Ingress, ConfigMap, Secret, and PVC. The image supports both `linux/amd64` and `linux/arm64`, making it suitable for cloud clusters and Raspberry Pi Kubernetes clusters.

## Content and backups

Portfolio content is stored in Supabase. Use the private editor for everyday updates. For a backup, use the Supabase project dashboard’s database backup/export tools. Keep the exported file in a secure location because it contains private contact messages and owner-managed content.

## Deployment workflow

The GitHub Actions workflow runs type checking, linting, and a production build for every pull request and push. A push to `main` also publishes an `amd64` and `arm64` image to GitHub Container Registry. The Helm chart can then deploy that image to a Kubernetes cluster.

## Important security notes

- The browser only receives the public Supabase key; privileged service keys are never placed in the frontend.
- Database row-level security protects editor writes and private draft access.
- Contact input is sent through Supabase and is not rendered as HTML.
- Credentials, verification IDs, and private message content should only be added through trusted owner access.
