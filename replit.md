# Police Emulation Scoring System

## Overview
This web application digitizes and streamlines the evaluation process for the Vietnamese People's Public Security force's "Vì An ninh Tổ quốc" emulation program. It manages self-scoring, cluster-level review, and final approval workflows across different organizational units. The system aims to ensure transparency, accuracy, and ease of data aggregation for competitive evaluations, supporting multiple evaluation periods per year with cluster-specific criteria. The business vision is to enhance the integrity and efficiency of performance evaluations within the Public Security force, improving national security efforts.

## User Preferences
Preferred communication style: Simple, everyday language.

## Recent Changes
- **November 18, 2025:** Added detailed criteria matrix table to Reports page showing unit-by-criteria scores with multi-level headers. Table displays all leaf criteria (TC1, TC2, TC3...) with ĐTC (self-score) and TĐ (cluster review score) sub-columns. Integrated into both interactive view and print layout. Backend ensures all cluster units appear even without scores (showing "-" for missing values). Added Excel export functionality with properly formatted multi-level headers matching the table structure.

## System Architecture

### Frontend Architecture
- **Framework:** React 18 with TypeScript, using Vite.
- **UI:** Shadcn/ui (Radix UI primitives), Material Design 3 principles, Tailwind CSS, Vietnamese localization.
- **State Management:** TanStack Query for server state, React hooks for local state, session-based authentication.
- **Routing:** Wouter.
- **Design Decisions:** Shadcn/ui for accessibility and customization. Material Design 3 for professional, data-intensive applications. Tailwind for rapid development. UX prioritizes selecting evaluation period then cluster. Auto-selection for user's cluster and unit. Hierarchical scoring distinguishes parent/branch (aggregating children's scores) and leaf nodes (direct user input). Display score prioritization favors auto-calculated scores for accuracy. Criteria matrix table with multi-level headers displays detailed unit-by-criteria breakdown. Printing and Excel export functionalities are implemented with security and proper data scoping.

### Backend Architecture
- **Runtime:** Node.js with Express.js.
- **Language:** TypeScript (ESM modules).
- **API Pattern:** RESTful API with session-based authentication.
- **Authentication:** Passport.js (Local Strategy), bcrypt for password hashing, express-session with PostgreSQL store.
- **Design Decisions:** Session-based authentication for enhanced security and audit trails. Passport.js for robust authentication. File attachments are served securely via protected routes. Recalculation endpoints support real-time and batch score updates, specifically for Type 1 criteria (quantitative). Security measures include enforcing `effectiveClusterId` for data access, preventing authorization bypasses in reports and exports.

### Data Layer
- **Database:** PostgreSQL (Neon serverless).
- **ORM:** Drizzle ORM.
- **Schema:**
    - `users`: Role-based access (admin, cluster_leader, user).
    - `clusters`: Evaluation cluster groups.
    - `units`: Police units within clusters.
    - `criteria_groups`: Evaluation criteria categories.
    - `criteria`: Specific evaluation criteria with max scores, `level`, and `code` for hierarchical trees.
    - `evaluation_periods`: Annual/periodic evaluation cycles, many-to-many with `clusters`.
    - `evaluations`: Self-scoring submissions.
    - `scores`: Granular scoring data.
    - `criteria_results`: Stores evaluation results, including `evidenceFile` (internal path) and `evidenceFileName` (original display name).
- **Key Relationships:** Users belong to Units, Units to Clusters. Criteria are scoped by `periodId` and optionally `clusterId`. Evaluations contain Scores.
- **Design Decisions:** Drizzle ORM for type-safety. Neon for serverless scalability. Normalized schema for flexible criteria and historical data, supporting multiple evaluation periods and cluster-specific criteria.

## External Dependencies
- **Database:** Neon PostgreSQL (`@neondatabase/serverless`).
- **Authentication:** `passport`, `passport-local`, `bcryptjs`.
- **Session Management:** `express-session`, `connect-pg-simple`.
- **UI Components:** `@radix-ui/*`, `class-variance-authority`, `tailwindcss`, `lucide-react`, `shadcn/ui`.
- **Form Handling:** `react-hook-form`, `@hookform/resolvers`, `zod`.
- **Excel Generation:** `exceljs`.