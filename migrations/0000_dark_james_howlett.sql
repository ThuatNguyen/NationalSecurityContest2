CREATE TABLE "clusters" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"short_name" text NOT NULL,
	"cluster_type" text NOT NULL,
	"description" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "clusters_name_unique" UNIQUE("name"),
	CONSTRAINT "clusters_short_name_unique" UNIQUE("short_name")
);
--> statement-breakpoint
CREATE TABLE "criteria" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"parent_id" varchar,
	"level" integer DEFAULT 1 NOT NULL,
	"name" text NOT NULL,
	"code" text,
	"description" text,
	"max_score" numeric(7, 2) DEFAULT '0' NOT NULL,
	"criteria_type" integer DEFAULT 0 NOT NULL,
	"formula_type" integer,
	"order_index" integer DEFAULT 0 NOT NULL,
	"period_id" varchar NOT NULL,
	"cluster_id" varchar NOT NULL,
	"is_active" integer DEFAULT 1 NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "criteria_bonus_penalty" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"criteria_id" varchar NOT NULL,
	"bonus_point" numeric(7, 2),
	"penalty_point" numeric(7, 2),
	"min_score" numeric(7, 2),
	"max_score" numeric(7, 2),
	"unit" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "criteria_bonus_penalty_criteria_id_unique" UNIQUE("criteria_id")
);
--> statement-breakpoint
CREATE TABLE "criteria_fixed_score" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"criteria_id" varchar NOT NULL,
	"point_per_unit" numeric(7, 2) NOT NULL,
	"max_score_limit" numeric(7, 2),
	"unit" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "criteria_fixed_score_criteria_id_unique" UNIQUE("criteria_id")
);
--> statement-breakpoint
CREATE TABLE "criteria_formula" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"criteria_id" varchar NOT NULL,
	"target_required" integer DEFAULT 1 NOT NULL,
	"default_target" numeric(10, 2),
	"unit" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "criteria_formula_criteria_id_unique" UNIQUE("criteria_id")
);
--> statement-breakpoint
CREATE TABLE "criteria_results" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"criteria_id" varchar NOT NULL,
	"unit_id" varchar NOT NULL,
	"period_id" varchar NOT NULL,
	"actual_value" numeric(10, 2),
	"self_score" numeric(7, 2),
	"bonus_count" integer DEFAULT 0,
	"penalty_count" integer DEFAULT 0,
	"calculated_score" numeric(7, 2),
	"cluster_score" numeric(7, 2),
	"final_score" numeric(7, 2),
	"note" text,
	"evidence_file" text,
	"evidence_file_name" text,
	"is_assigned" boolean DEFAULT true NOT NULL,
	"status" text DEFAULT 'draft' NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "criteria_results_criteria_id_unit_id_period_id_unique" UNIQUE("criteria_id","unit_id","period_id")
);
--> statement-breakpoint
CREATE TABLE "criteria_targets" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"criteria_id" varchar NOT NULL,
	"unit_id" varchar NOT NULL,
	"period_id" varchar NOT NULL,
	"target_value" numeric(10, 2) NOT NULL,
	"note" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "criteria_targets_criteria_id_unit_id_period_id_unique" UNIQUE("criteria_id","unit_id","period_id")
);
--> statement-breakpoint
CREATE TABLE "evaluation_period_clusters" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"period_id" varchar NOT NULL,
	"cluster_id" varchar NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "evaluation_period_clusters_period_id_cluster_id_unique" UNIQUE("period_id","cluster_id")
);
--> statement-breakpoint
CREATE TABLE "evaluation_periods" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"year" integer NOT NULL,
	"start_date" timestamp NOT NULL,
	"end_date" timestamp NOT NULL,
	"status" text DEFAULT 'draft' NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "evaluations" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"period_id" varchar NOT NULL,
	"cluster_id" varchar NOT NULL,
	"unit_id" varchar NOT NULL,
	"status" text DEFAULT 'draft' NOT NULL,
	"total_self_score" numeric(7, 2),
	"total_review1_score" numeric(7, 2),
	"total_review2_score" numeric(7, 2),
	"total_final_score" numeric(7, 2),
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "evaluations_period_id_unit_id_unique" UNIQUE("period_id","unit_id")
);
--> statement-breakpoint
CREATE TABLE "units" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"short_name" text NOT NULL,
	"cluster_id" varchar NOT NULL,
	"description" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "units_name_unique" UNIQUE("name"),
	CONSTRAINT "units_short_name_unique" UNIQUE("short_name")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"username" text NOT NULL,
	"password" text NOT NULL,
	"full_name" text NOT NULL,
	"role" text DEFAULT 'user' NOT NULL,
	"cluster_id" varchar,
	"unit_id" varchar,
	"require_password_reset" boolean DEFAULT false NOT NULL,
	"last_password_change" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_username_unique" UNIQUE("username")
);
--> statement-breakpoint
ALTER TABLE "criteria" ADD CONSTRAINT "criteria_parent_id_criteria_id_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."criteria"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria" ADD CONSTRAINT "criteria_period_id_evaluation_periods_id_fk" FOREIGN KEY ("period_id") REFERENCES "public"."evaluation_periods"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria" ADD CONSTRAINT "criteria_cluster_id_clusters_id_fk" FOREIGN KEY ("cluster_id") REFERENCES "public"."clusters"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_bonus_penalty" ADD CONSTRAINT "criteria_bonus_penalty_criteria_id_criteria_id_fk" FOREIGN KEY ("criteria_id") REFERENCES "public"."criteria"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_fixed_score" ADD CONSTRAINT "criteria_fixed_score_criteria_id_criteria_id_fk" FOREIGN KEY ("criteria_id") REFERENCES "public"."criteria"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_formula" ADD CONSTRAINT "criteria_formula_criteria_id_criteria_id_fk" FOREIGN KEY ("criteria_id") REFERENCES "public"."criteria"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_results" ADD CONSTRAINT "criteria_results_criteria_id_criteria_id_fk" FOREIGN KEY ("criteria_id") REFERENCES "public"."criteria"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_results" ADD CONSTRAINT "criteria_results_unit_id_units_id_fk" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_results" ADD CONSTRAINT "criteria_results_period_id_evaluation_periods_id_fk" FOREIGN KEY ("period_id") REFERENCES "public"."evaluation_periods"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_targets" ADD CONSTRAINT "criteria_targets_criteria_id_criteria_id_fk" FOREIGN KEY ("criteria_id") REFERENCES "public"."criteria"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_targets" ADD CONSTRAINT "criteria_targets_unit_id_units_id_fk" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "criteria_targets" ADD CONSTRAINT "criteria_targets_period_id_evaluation_periods_id_fk" FOREIGN KEY ("period_id") REFERENCES "public"."evaluation_periods"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "evaluation_period_clusters" ADD CONSTRAINT "evaluation_period_clusters_period_id_evaluation_periods_id_fk" FOREIGN KEY ("period_id") REFERENCES "public"."evaluation_periods"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "evaluation_period_clusters" ADD CONSTRAINT "evaluation_period_clusters_cluster_id_clusters_id_fk" FOREIGN KEY ("cluster_id") REFERENCES "public"."clusters"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "evaluations" ADD CONSTRAINT "evaluations_period_id_evaluation_periods_id_fk" FOREIGN KEY ("period_id") REFERENCES "public"."evaluation_periods"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "evaluations" ADD CONSTRAINT "evaluations_cluster_id_clusters_id_fk" FOREIGN KEY ("cluster_id") REFERENCES "public"."clusters"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "evaluations" ADD CONSTRAINT "evaluations_unit_id_units_id_fk" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "units" ADD CONSTRAINT "units_cluster_id_clusters_id_fk" FOREIGN KEY ("cluster_id") REFERENCES "public"."clusters"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_cluster_id_clusters_id_fk" FOREIGN KEY ("cluster_id") REFERENCES "public"."clusters"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_unit_id_units_id_fk" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "criteria_period_cluster_idx" ON "criteria" USING btree ("period_id","cluster_id","parent_id","order_index");