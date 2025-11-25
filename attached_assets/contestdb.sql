--
-- PostgreSQL database dump
--

\restrict goXCA6UuexK0pYiTvnbw56H9QBjlRyLi3h18v9WOf697Tr4cCw4FNzX49MBL6Y4

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clusters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clusters (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    short_name text NOT NULL,
    cluster_type text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.clusters OWNER TO postgres;

--
-- Name: criteria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criteria (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    parent_id character varying,
    level integer DEFAULT 1 NOT NULL,
    name text NOT NULL,
    code text,
    description text,
    max_score numeric(7,2) DEFAULT '0'::numeric NOT NULL,
    criteria_type integer DEFAULT 0 NOT NULL,
    formula_type integer,
    order_index integer DEFAULT 0 NOT NULL,
    period_id character varying NOT NULL,
    cluster_id character varying NOT NULL,
    is_active integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.criteria OWNER TO postgres;

--
-- Name: criteria_bonus_penalty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criteria_bonus_penalty (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    criteria_id character varying NOT NULL,
    bonus_point numeric(7,2),
    penalty_point numeric(7,2),
    min_score numeric(7,2),
    max_score numeric(7,2),
    unit text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.criteria_bonus_penalty OWNER TO postgres;

--
-- Name: criteria_fixed_score; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criteria_fixed_score (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    criteria_id character varying NOT NULL,
    point_per_unit numeric(7,2) NOT NULL,
    max_score_limit numeric(7,2),
    unit text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.criteria_fixed_score OWNER TO postgres;

--
-- Name: criteria_formula; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criteria_formula (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    criteria_id character varying NOT NULL,
    target_required integer DEFAULT 1 NOT NULL,
    default_target numeric(10,2),
    unit text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.criteria_formula OWNER TO postgres;

--
-- Name: criteria_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criteria_results (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    criteria_id character varying NOT NULL,
    unit_id character varying NOT NULL,
    period_id character varying NOT NULL,
    actual_value numeric(10,2),
    self_score numeric(7,2),
    bonus_count integer DEFAULT 0,
    penalty_count integer DEFAULT 0,
    calculated_score numeric(7,2),
    cluster_score numeric(7,2),
    final_score numeric(7,2),
    note text,
    evidence_file text,
    evidence_file_name text,
    status text DEFAULT 'draft'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.criteria_results OWNER TO postgres;

--
-- Name: criteria_targets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criteria_targets (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    criteria_id character varying NOT NULL,
    unit_id character varying NOT NULL,
    period_id character varying NOT NULL,
    target_value numeric(10,2) NOT NULL,
    note text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.criteria_targets OWNER TO postgres;

--
-- Name: evaluation_period_clusters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evaluation_period_clusters (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    period_id character varying NOT NULL,
    cluster_id character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.evaluation_period_clusters OWNER TO postgres;

--
-- Name: evaluation_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evaluation_periods (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    year integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.evaluation_periods OWNER TO postgres;

--
-- Name: evaluations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evaluations (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    period_id character varying NOT NULL,
    cluster_id character varying NOT NULL,
    unit_id character varying NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    total_self_score numeric(7,2),
    total_review1_score numeric(7,2),
    total_review2_score numeric(7,2),
    total_final_score numeric(7,2),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.evaluations OWNER TO postgres;

--
-- Name: scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scores (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    evaluation_id character varying NOT NULL,
    criteria_id character varying NOT NULL,
    actual_value numeric(10,2),
    count integer,
    bonus_count integer DEFAULT 0,
    penalty_count integer DEFAULT 0,
    is_achieved integer,
    calculated_score numeric(7,2),
    self_score numeric(5,2),
    self_score_file text,
    self_score_date timestamp without time zone,
    review1_score numeric(5,2),
    review1_comment text,
    review1_file text,
    review1_date timestamp without time zone,
    review1_by character varying,
    explanation text,
    explanation_file text,
    explanation_date timestamp without time zone,
    review2_score numeric(5,2),
    review2_comment text,
    review2_file text,
    review2_date timestamp without time zone,
    review2_by character varying,
    final_score numeric(5,2),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.scores OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.units (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    short_name text NOT NULL,
    cluster_id character varying NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.units OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    full_name text NOT NULL,
    role text DEFAULT 'user'::text NOT NULL,
    cluster_id character varying,
    unit_id character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: clusters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clusters (id, name, short_name, cluster_type, description, created_at, updated_at) FROM stdin;
99432257-142b-4c62-80cc-db9d02d09164	Cụm Công an cấp Phòng Thành phố	CACPTP	phong	Cụm thi đua các đơn vị Công an cấp phòng thuộc Thành phố	2025-11-22 17:01:25.247311	2025-11-22 17:01:25.247311
799ffdd8-29b4-4d31-b899-5c02a7ea65bd	Cụm Công an xã/phường Quận 1	CAXPQ1	xa_phuong	Cụm thi đua Công an các xã, phường thuộc Quận 1	2025-11-22 17:01:25.247311	2025-11-22 17:01:25.247311
e94c3da5-034a-46e5-873e-563045dbaea9	Cụm Công an xã/phường Quận 3	CAXPQ3	xa_phuong	Cụm thi đua Công an các xã, phường thuộc Quận 3	2025-11-22 17:01:25.247311	2025-11-22 17:01:25.247311
80ef8ccc-fe70-4352-9e59-44735eeb3378	Cụm thi đua số 347	CỤM 347	xa_phuong		2025-11-23 15:32:59.358864	2025-11-23 15:32:59.358864
\.


--
-- Data for Name: criteria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.criteria (id, parent_id, level, name, code, description, max_score, criteria_type, formula_type, order_index, period_id, cluster_id, is_active, created_at, updated_at) FROM stdin;
36774c85-9925-46a4-a364-2448d858840c	e8fffde2-7691-491b-a1e5-3fe6d2b5d8d9	2	Công tác bảo vệ an ninh quốc gia	1.	\N	200.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 15:56:26.161825	2025-11-23 15:56:26.161825
e8fffde2-7691-491b-a1e5-3fe6d2b5d8d9	\N	1	NHIỆM VỤ CÔNG TÁC CHUYÊN MÔN	I.	\N	700.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 15:50:45.896594	2025-11-23 08:56:38.401
56f29ca5-e0a3-43e1-b78e-023a4fc1b67f	\N	1	CÔNG TÁC XÂY DỰNG ĐẢNG, XÂY DỰNG LỰC LƯỢNG, HẬU CẦN, KỸ THUẬT, CẢI CÁCH HÀNH CHÍNH, TƯ PHÁP	II.	\N	200.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 15:54:37.207156	2025-11-23 08:56:51.06
54a1fed9-2772-4472-aaaa-97becf2db886	\N	1	TỔ CHỨC PHONG TRÀO THI ĐUA	III.	\N	100.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 15:53:10.38128	2025-11-23 08:56:58.786
0291ac0f-a491-4903-a0ce-f5fb7dbea7d7	e8fffde2-7691-491b-a1e5-3fe6d2b5d8d9	2	Công tác đấu tranh phòng, chống tội phạm	2.	\N	200.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 15:58:47.605018	2025-11-23 15:58:47.605018
04eec732-2426-40ac-94ab-b58f2b4fe5b0	e8fffde2-7691-491b-a1e5-3fe6d2b5d8d9	2	Công tác NVCB	4.	\N	100.00	0	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:05:20.18045	2025-11-23 16:05:20.18045
19368a6c-671b-46da-9f6c-cfd234b537b6	e8fffde2-7691-491b-a1e5-3fe6d2b5d8d9	2	Công tác xây dựng phong trào toàn dân bảo vệ ANTQ	5.	\N	40.00	0	\N	5	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:05:57.279679	2025-11-23 16:05:57.279679
b94bd25c-5f3e-43ea-98c5-11138b5095c3	e8fffde2-7691-491b-a1e5-3fe6d2b5d8d9	2	Công tác tham mưu, hồ sơ nghiệp vụ, đối ngoại, hợp tác, hồ sơ nghiệp vụ	6.	\N	40.00	0	\N	6	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:08:07.809709	2025-11-23 16:08:07.809709
8d7c9ab8-8883-4bbe-a42b-64dfd71dcb77	e8fffde2-7691-491b-a1e5-3fe6d2b5d8d9	2	Công tác quản lý nhà nước về trật tự xã hội	3.	\N	120.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:17:17.126552	2025-11-23 16:17:17.126552
7698918c-dccc-4fff-b249-7db457c152e4	56f29ca5-e0a3-43e1-b78e-023a4fc1b67f	2	Công tác pháp chế, cải cách hành chính, tư pháp và nghiên cứu khoa học	5.	\N	30.00	0	\N	5	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:20:59.603182	2025-11-23 16:20:59.603182
512d5d4a-cbf3-460e-9f74-a0b3bcca50ae	56f29ca5-e0a3-43e1-b78e-023a4fc1b67f	1	Công tác thanh tra, kiểm tra, giải quyết khiếu nại, tố cáo	3.	\N	30.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:19:14.364202	2025-11-24 08:02:48.302
d2e851bc-4408-4b55-9aeb-7a551d790f09	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 1	1	\N	50.00	2	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:28:34.749017	2025-11-23 12:03:54.88
b8ee94cd-6988-47b8-8e43-67193def36b6	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 2	2	\N	10.00	2	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:30:49.713858	2025-11-23 12:04:17.796
f4bf6416-f972-4d4e-99e8-04a89fd369e2	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 3	3	\N	10.00	2	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:32:36.068241	2025-11-23 12:04:41.728
1b32643f-336d-42af-bb06-99423ec5e622	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 4	4	\N	10.00	2	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:34:14.32008	2025-11-23 12:04:50.844
98b52742-77b5-4a61-a42c-ab4dba2c9474	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 5	5	\N	10.00	2	\N	5	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:35:26.252534	2025-11-23 12:05:17.411
3f6ec771-2eb2-49db-8ed1-34966a98fba9	56f29ca5-e0a3-43e1-b78e-023a4fc1b67f	1	Công tác chính trị	1.	\N	50.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:10:00.805879	2025-11-24 08:02:29.849
5d5d1689-e886-46c4-bf92-e2a661c69b34	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 6	6	\N	20.00	0	\N	6	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:37:18.94971	2025-11-23 12:05:41.459
68a08d0e-6535-4e43-adeb-fa90fa585e59	54a1fed9-2772-4472-aaaa-97becf2db886	1	Tích cực đăng cai, phối hợp thực hiện nhiệm vụ đột xuất được Công an tỉnh giao trở lên	4.	Bao gồm tổng điểm của các tiêu chí 154,155,156,157	25.00	3	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:25:43.048918	2025-11-24 07:44:18.834
168f3175-150e-41ad-a12e-2bddbe7c6464	3f6ec771-2eb2-49db-8ed1-34966a98fba9	1	Công tác đoàn, thanh niên	1.d)	\N	5.00	0	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:25:55.10635	2025-11-24 07:52:46.792
7f6fb1db-9b08-4d08-96de-78ba68b1584c	56f29ca5-e0a3-43e1-b78e-023a4fc1b67f	1	Công tác tài chính, hậu cần, kỹ thuật	4.	\N	40.00	0	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:20:05.072537	2025-11-24 07:58:10.194
7e9133e5-1f08-4af6-b82b-5591bb20c7e6	56f29ca5-e0a3-43e1-b78e-023a4fc1b67f	1	Công tác tổ chức cán bộ	2.	\N	50.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:13:03.39629	2025-11-24 08:02:40.313
841834be-9133-47a0-8b4b-f49e53770d79	54a1fed9-2772-4472-aaaa-97becf2db886	1	Kết quả công tác khen thưởng	2.	\N	20.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:22:57.512158	2025-11-24 08:03:09.174
49a64260-903e-492a-8a56-ab78c434dae7	54a1fed9-2772-4472-aaaa-97becf2db886	1	Tham gia hội thao, hội thi, hội diễn, cuộc thi do Công an tỉnh tổ chức trở lên	3.	\N	15.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:24:21.83459	2025-11-24 08:03:13.023
0665d813-c605-4a69-956f-245763cd28e9	5d5d1689-e886-46c4-bf92-e2a661c69b34	1	Tiêu chí 6a	6a	\N	10.00	2	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:38:27.349272	2025-11-23 12:06:02.241
5d3f47f8-725f-46d5-9d63-3c0e66c009d2	72e1969e-7840-4d28-9f4d-f8acbc9bba8d	1	Tiêu chí số 11a	11a	\N	10.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:05:23.950753	2025-11-23 14:06:01.576
192373fa-3b89-4f2a-8586-59adb080dc94	0291ac0f-a491-4903-a0ce-f5fb7dbea7d7	3	Công tác đấu tranh phòng, chống tội phạm và vi phạm pháp luật về ma túy	2.d)	\N	50.00	0	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:14:11.732556	2025-11-23 17:14:11.732556
5c54ab57-4855-4767-9036-3798829a2eeb	8d7c9ab8-8883-4bbe-a42b-64dfd71dcb77	3	Công tác quản lý hành chính về trật tự xã hội	3.a)	\N	40.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:15:09.368244	2025-11-23 17:15:09.368244
29ea52a9-4758-4699-9930-e3dcbc077908	8d7c9ab8-8883-4bbe-a42b-64dfd71dcb77	3	Công tác phòng chống cháy nổ	3.b)	\N	30.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:15:55.303778	2025-11-23 17:15:55.303778
acf3445d-a18e-4227-8df1-02994a9af894	8d7c9ab8-8883-4bbe-a42b-64dfd71dcb77	3	Công tác bảo đảm trật tự, an toàn giao thông	3.c)	\N	30.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:16:44.333564	2025-11-23 17:16:44.333564
9884db42-7fc5-4e9c-a9c3-8aec621ebb55	04eec732-2426-40ac-94ab-b58f2b4fe5b0	3	Công tác NVCB lực lượng An ninh	4.a)	\N	50.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:18:10.520907	2025-11-23 17:18:10.520907
7f73d34c-5a99-42ff-9c10-36e69d16e4a5	04eec732-2426-40ac-94ab-b58f2b4fe5b0	3	Công tác NVCB lực lượng CSND	4.b)	\N	50.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:19:33.390776	2025-11-23 17:19:33.390776
ab174e0f-5d07-4ee0-80de-58e952cfacfa	5d5d1689-e886-46c4-bf92-e2a661c69b34	1	Tiêu chí 6b	6b	\N	10.00	2	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:39:31.237681	2025-11-23 12:06:17.81
8c181441-36a7-432a-a2de-2026909f9a41	72e1969e-7840-4d28-9f4d-f8acbc9bba8d	1	Tiêu chí số 11b	11b	\N	10.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:06:14.994856	2025-11-23 14:06:10.49
6895035a-8d90-4f60-874f-253a675eb019	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 9	9	\N	20.00	0	\N	9	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:55:39.495537	2025-11-23 12:07:48.849
a950378f-5714-47b4-a0b0-a18de16defd1	0291ac0f-a491-4903-a0ce-f5fb7dbea7d7	1	Công tác điều tra, xử lý tội phạm	2.a)	\N	70.00	0	\N	0	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:09:40.918586	2025-11-24 07:49:06.582
2f31b0fb-8fa1-431c-baff-a39b4494532a	0291ac0f-a491-4903-a0ce-f5fb7dbea7d7	1	Công tác đấu tranh phòng, chống tội phạm về trật tự xã hội	2.b)	\N	50.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:10:40.962899	2025-11-24 07:49:19.454
72e1969e-7840-4d28-9f4d-f8acbc9bba8d	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí 11	11	\N	20.00	0	\N	11	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:03:37.368526	2025-11-23 12:09:29.606
2727281f-30a6-451a-8aa7-adf9d33434af	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 12	12	\N	10.00	2	\N	12	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:07:19.599848	2025-11-23 12:09:53.694
59906472-16d5-41b3-a03c-ab016f580617	3f6ec771-2eb2-49db-8ed1-34966a98fba9	1	Công tác điều lệnh, quân sự, võ thuật, văn thể	1.c)	\N	15.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:24:26.333412	2025-11-24 07:52:32.609
6fa1f4e3-a5e3-4439-9d35-a7234323aed6	3f6ec771-2eb2-49db-8ed1-34966a98fba9	1	Công tác thi đua khen thưởng	1.b)	\N	10.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:23:02.761761	2025-11-24 07:52:15.222
acd2fed3-2d5b-4223-a8b7-160c1194c9e6	0291ac0f-a491-4903-a0ce-f5fb7dbea7d7	1	Công tác đấu tranh phòng, chống tội phạm về kinh tế, buôn lậu, môi trường	2.c)	\N	30.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:12:32.257279	2025-11-23 12:25:28.98
381a96ff-c413-4412-8b19-3c0117aea3ec	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 7	7	\N	20.00	3	\N	7	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 16:52:04.729457	2025-11-23 14:04:44.336
7313230c-811c-45e7-ba72-bc8ebcd65f7a	6895035a-8d90-4f60-874f-253a675eb019	1	Tiêu chí 9a	9a	\N	10.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:00:58.861012	2025-11-23 14:05:14.588
d32ec9db-b64f-42c7-a21e-16a443599cf5	6895035a-8d90-4f60-874f-253a675eb019	1	Tiêu chí số 9b	9b	\N	10.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:01:29.140316	2025-11-23 14:05:22.479
ef8f8ad5-2255-4292-a371-a681701526bc	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 10	10	\N	10.00	3	\N	10	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 17:02:33.571417	2025-11-23 14:05:47.85
d574da97-c404-48bc-8ddb-1d0dd6943d04	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 15	15	\N	5.00	2	\N	15	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:12:26.726193	2025-11-23 12:12:35.584
c684de0e-7f27-4e91-87a3-4f5ae46156bc	7f769331-cd6f-4079-a2c4-fdd32214b33f	3	Tiêu chí số 28b	28b	\N	5.00	1	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:30:28.847807	2025-11-23 19:30:28.847807
fa96f655-905e-4a20-b489-8c8d3295ec83	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 16	16	\N	5.00	2	\N	16	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:12:50.933214	2025-11-23 12:13:33.49
c981c60d-9dec-44ef-bbba-5973de4977b2	acd2fed3-2d5b-4223-a8b7-160c1194c9e6	2	Tiêu chí số 29	29	\N	5.00	2	\N	29	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:31:30.051668	2025-11-23 19:31:30.051668
5620079f-e61f-4e50-8571-a5c2dd9de71e	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 20	20	\N	10.00	1	\N	20	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:18:30.726212	2025-11-23 12:20:08.892
6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	a950378f-5714-47b4-a0b0-a18de16defd1	4	Tiêu chí số 21	21	\N	5.00	1	\N	21	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:20:56.848391	2025-11-23 19:20:56.848391
309b57b1-e23c-41c0-9d69-175782810453	2f31b0fb-8fa1-431c-baff-a39b4494532a	1	Tiêu chí số 22	22	\N	20.00	1	\N	22	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:21:34.966493	2025-11-23 12:21:43.307
da26b8bc-3aa4-4c7e-b005-c2a79d369cba	2f31b0fb-8fa1-431c-baff-a39b4494532a	4	Tiêu chí số 23	23	\N	10.00	1	\N	23	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:22:18.490192	2025-11-23 19:22:18.490192
a4f478bf-d50d-4fe6-a339-de512cbbab8b	2f31b0fb-8fa1-431c-baff-a39b4494532a	4	Tiêu chí số 24	24	\N	5.00	2	\N	24	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:22:58.591286	2025-11-23 19:22:58.591286
9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	2f31b0fb-8fa1-431c-baff-a39b4494532a	4	Tiêu chí số 25	25	\N	5.00	2	\N	25	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:23:29.183248	2025-11-23 19:23:29.183248
60087a36-e314-4fc1-b4d7-9aa1a33e4109	2f31b0fb-8fa1-431c-baff-a39b4494532a	4	Tiêu chí số 26	26	\N	10.00	1	\N	26	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:24:09.345296	2025-11-23 19:24:09.345296
eca6b514-c822-40de-8773-1fb5ec63944c	acd2fed3-2d5b-4223-a8b7-160c1194c9e6	1	Tiêu chí số 27	27	\N	15.00	0	\N	27	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:24:50.995691	2025-11-23 12:26:31.597
600a025b-0c42-4f27-9475-0316676f584c	eca6b514-c822-40de-8773-1fb5ec63944c	2	Tiêu chí số 27a	27a	\N	5.00	1	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:27:07.560462	2025-11-23 19:27:07.560462
f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	eca6b514-c822-40de-8773-1fb5ec63944c	2	Tiêu chí số 27b	27b	\N	5.00	1	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:27:38.483806	2025-11-23 19:27:38.483806
8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	eca6b514-c822-40de-8773-1fb5ec63944c	2	Tiêu chí số 27c	27c	\N	5.00	1	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:28:09.300088	2025-11-23 19:28:09.300088
7f769331-cd6f-4079-a2c4-fdd32214b33f	acd2fed3-2d5b-4223-a8b7-160c1194c9e6	2	Tiêu chí số 28	28	\N	10.00	0	\N	28	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:29:20.804316	2025-11-23 19:29:20.804316
4b68575e-b415-45b1-9338-b43937cb7a76	7f769331-cd6f-4079-a2c4-fdd32214b33f	3	Tiêu chí số 28a	28a	\N	5.00	1	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:29:49.878657	2025-11-23 19:29:49.878657
d9337788-d07b-487e-a8ea-79bd9a237706	5c54ab57-4855-4767-9036-3798829a2eeb	4	Tiêu chí số 35	35	\N	5.00	3	\N	35	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:51:54.184307	2025-11-23 20:51:54.184307
8a5ebc3d-20ee-4780-b286-64c434c87a72	5c54ab57-4855-4767-9036-3798829a2eeb	4	Tiêu chí số 36	36	\N	5.00	2	\N	36	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:52:54.494865	2025-11-23 20:52:54.494865
bb2e4d2d-e679-4c62-a88e-ce92baaf2368	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 14	14	\N	10.00	3	\N	14	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:12:05.390379	2025-11-23 14:06:40.926
e14f39a3-c101-44d1-9bfa-66b6b7ce4829	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 17	17	\N	10.00	3	\N	17	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:16:44.022987	2025-11-23 14:06:57.913
4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 18	18	\N	5.00	3	\N	18	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:17:06.257701	2025-11-23 14:07:14.615
87605a36-1a09-42c9-8362-ee3f79925b46	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 19	19	\N	10.00	3	\N	19	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:17:47.663944	2025-11-23 14:07:28.707
be878744-4347-47da-9a82-7a1dde8a1077	192373fa-3b89-4f2a-8586-59adb080dc94	1	Tiêu chí số 34	34	\N	10.00	3	\N	34	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:50:26.138104	2025-11-23 14:09:01.078
02507c7a-6a42-4bdc-a8b8-79cc07d58eac	a950378f-5714-47b4-a0b0-a18de16defd1	1	Tiêu chí số 13	13	\N	10.00	2	\N	13	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:11:36.369322	2025-11-24 08:05:03.352
267e5cb1-334e-4830-beb1-d94707b486bb	192373fa-3b89-4f2a-8586-59adb080dc94	1	Tiêu chí số 30	30	\N	10.00	2	\N	30	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:33:07.61129	2025-11-24 08:05:24.083
7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	192373fa-3b89-4f2a-8586-59adb080dc94	1	Tiêu chí số 31	31	\N	10.00	1	\N	31	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:34:00.446564	2025-11-24 08:05:27.816
165aae17-5f5b-476e-bd69-05c16e9e4c24	192373fa-3b89-4f2a-8586-59adb080dc94	1	Tiêu chí số 32	32	\N	15.00	1	\N	32	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:34:27.635655	2025-11-24 08:05:32.703
7112a886-e9b0-4e40-80ef-a73f9cba962e	192373fa-3b89-4f2a-8586-59adb080dc94	1	Tiêu chí số 33	33	\N	5.00	2	\N	33	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:49:52.898666	2025-11-24 08:05:46.073
eb7bd701-5795-43cc-8391-21426990fbb5	5c54ab57-4855-4767-9036-3798829a2eeb	4	Tiêu chí số 37	37	\N	5.00	3	\N	37	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:53:34.689976	2025-11-23 20:53:34.689976
bd51fb3a-a296-460a-9e82-7baa5a368999	5c54ab57-4855-4767-9036-3798829a2eeb	4	Tiêu chí số 38	38	\N	15.00	0	\N	38	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:54:14.357652	2025-11-23 20:54:14.357652
d1635049-c122-4492-9597-7e125fcf09f8	bd51fb3a-a296-460a-9e82-7baa5a368999	5	Tiêu chí số 38a	38a	\N	5.00	3	\N	0	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:54:57.423983	2025-11-23 20:54:57.423983
26857eb0-eb02-4639-a4fd-b38ed6a6ca30	bd51fb3a-a296-460a-9e82-7baa5a368999	5	Tiêu chí số 38b	38b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:55:20.398314	2025-11-23 20:55:20.398314
141ea20f-cf29-48a2-b367-6ac07a5bd7b4	bd51fb3a-a296-460a-9e82-7baa5a368999	5	Tiêu chí số 38c	38c	\N	5.00	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:55:48.395495	2025-11-23 20:55:48.395495
0bc8013a-804f-45f8-a28c-d03d2e014450	5c54ab57-4855-4767-9036-3798829a2eeb	4	Tiêu chí số 39	39	\N	5.00	0	\N	39	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:56:33.519237	2025-11-23 20:56:33.519237
20b83a28-4fe7-4d6c-a242-f5f8462c6e14	0bc8013a-804f-45f8-a28c-d03d2e014450	5	Tiêu chí số 39b	39b	\N	2.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:57:31.219915	2025-11-23 20:57:31.219915
bdf2e59f-8c98-4df8-bc36-dc4573a0606b	0bc8013a-804f-45f8-a28c-d03d2e014450	1	Tiêu chí số 39a	39a	\N	3.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:56:53.435592	2025-11-23 13:57:45.275
246965b3-e65a-48f9-9f68-fdda80be8169	5c54ab57-4855-4767-9036-3798829a2eeb	4	Tiêu chí 40	40	\N	5.00	3	\N	40	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:58:48.547091	2025-11-23 20:58:48.547091
417d134f-c87f-4f9b-853c-f249d86e512d	29ea52a9-4758-4699-9930-e3dcbc077908	1	Tiêu chí số 41	41	\N	15.00	0	\N	41	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 20:59:49.243717	2025-11-23 14:00:18.042
db9717f5-c7a7-4532-97b1-e33f0ec86750	417d134f-c87f-4f9b-853c-f249d86e512d	1	Tiêu chí số 41b	41b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:01:36.683183	2025-11-23 14:01:47.788
31466b47-7a2c-48d7-a4aa-cde19dfabc5f	417d134f-c87f-4f9b-853c-f249d86e512d	2	Tiêu chí số 41c	41c	\N	5.00	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:02:14.954368	2025-11-23 21:02:14.954368
750d4861-d84c-4622-a0f5-e709289e603b	29ea52a9-4758-4699-9930-e3dcbc077908	4	Tiêu chí số 42	42	\N	5.00	3	\N	42	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:03:19.070426	2025-11-23 21:03:19.070426
97ee726a-f9c6-4c65-9794-543a6feb7a1b	29ea52a9-4758-4699-9930-e3dcbc077908	4	Tiêu chí số 43	43	\N	10.00	3	\N	43	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:03:51.86346	2025-11-23 21:03:51.86346
cc239035-3c1b-41b2-a71a-2a43f5728543	36774c85-9925-46a4-a364-2448d858840c	1	Tiêu chí số 8	8	\N	10.00	3	\N	8	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 19:07:28.529156	2025-11-23 14:05:38.976
caab4c86-09b7-4e17-b659-534ccf07bff7	8d7c9ab8-8883-4bbe-a42b-64dfd71dcb77	3	Công tác thi hành án hình sự, hỗ trợ tư pháp, tái hòa nhập cộng đồng	3.d)	\N	20.00	0	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:15:20.356846	2025-11-23 21:15:20.356846
973abd8b-5798-4c77-912f-2f036e0e2d28	acf3445d-a18e-4227-8df1-02994a9af894	1	Tiêu chí số 45	45	\N	5.00	2	\N	45	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:11:00.790602	2025-11-23 14:13:11.735
a03680b8-7258-4d8f-95dc-29aaba658479	acf3445d-a18e-4227-8df1-02994a9af894	1	Tiêu chí số 46	46	\N	10.00	2	\N	46	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:11:19.109827	2025-11-23 14:13:19.142
4ee3df5c-a054-4b93-9f97-52a99196cdfe	acf3445d-a18e-4227-8df1-02994a9af894	1	Tiêu chí số 47	47	\N	5.00	2	\N	47	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:11:58.287113	2025-11-23 14:13:27.214
18aaf397-5d9c-42f9-a327-fa0fba8d477d	13e521c8-3e4d-40b3-9c93-9635b2784272	1	Tiêu chí số 49c	49c	\N	1.00	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:18:57.954443	2025-11-23 14:20:07.703
300cdf79-1132-4e9e-b99c-d8971dedf35d	9884db42-7fc5-4e9c-a9c3-8aec621ebb55	4	Tiêu chí số 51	51	\N	10.00	0	\N	51	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:20:55.686577	2025-11-23 21:20:55.686577
884e9fae-75d3-483c-b444-a464ac0130b9	300cdf79-1132-4e9e-b99c-d8971dedf35d	5	Tiêu chí số 51a	51a	\N	5.00	2	\N	0	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:21:27.433401	2025-11-23 21:21:27.433401
ffe4c55a-155d-409f-ad66-49ed6be0ded7	300cdf79-1132-4e9e-b99c-d8971dedf35d	5	Tiêu chí số 51b	51b	\N	5.00	2	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:21:58.042732	2025-11-23 21:21:58.042732
e42f3146-91be-4122-ab94-001552f7dd82	9884db42-7fc5-4e9c-a9c3-8aec621ebb55	4	Tiêu chí số 52	52	\N	10.00	0	\N	52	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:23:27.536176	2025-11-23 21:23:27.536176
485d3228-8245-454e-bc68-f2ce6c944263	e42f3146-91be-4122-ab94-001552f7dd82	5	Tiêu chí số 52a	52a	\N	5.00	3	\N	0	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:24:10.165673	2025-11-23 21:24:10.165673
1f752b6d-e8ff-4061-97f6-310f6fa0664b	acf3445d-a18e-4227-8df1-02994a9af894	1	Tiêu chí số 44	44	\N	10.00	3	\N	44	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:10:39.224381	2025-11-24 07:49:59.476
285c236b-e5a0-4f89-89ca-6f9b140fd0ab	13e521c8-3e4d-40b3-9c93-9635b2784272	1	Tiêu chí số 49a	49a	\N	3.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:17:09.81314	2025-11-24 07:50:09.351
c869685a-fd7e-46ed-8af6-9d8c6b74f9de	caab4c86-09b7-4e17-b659-534ccf07bff7	1	Tiêu chí số 50	50	\N	4.00	2	\N	50	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:19:54.023686	2025-11-24 08:44:47.97
23db48b5-e04d-4351-b095-bdf2defff0c4	caab4c86-09b7-4e17-b659-534ccf07bff7	1	Tiêu chí số 48	48	\N	8.00	3	\N	48	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:16:08.894908	2025-11-24 08:46:15.449
13e521c8-3e4d-40b3-9c93-9635b2784272	caab4c86-09b7-4e17-b659-534ccf07bff7	1	Tiêu chí số 49	49	\N	8.00	0	\N	49	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:16:34.108629	2025-11-24 08:46:23.611
94b798d5-13b9-49ad-9d22-228a3f07bfb5	e42f3146-91be-4122-ab94-001552f7dd82	5	Tiêu chí số 52b	52b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:24:31.97383	2025-11-23 21:24:31.97383
ebc2d466-afd8-4c93-a009-c40784b51f9d	9884db42-7fc5-4e9c-a9c3-8aec621ebb55	4	Tiêu chí số 53	53	\N	20.00	0	\N	53	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:30:44.983029	2025-11-23 21:30:44.983029
8df81618-19da-478a-90c1-e9e2a15429c8	9884db42-7fc5-4e9c-a9c3-8aec621ebb55	4	Tiêu chí số 54	54	\N	10.00	0	\N	54	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:31:38.259254	2025-11-23 21:31:38.259254
c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	ebc2d466-afd8-4c93-a009-c40784b51f9d	1	Tiêu chí số 53b	53b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:32:58.687137	2025-11-23 14:33:04.885
eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	ebc2d466-afd8-4c93-a009-c40784b51f9d	1	Tiêu chí số 53c	53c	\N	5.00	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:33:35.99425	2025-11-23 14:33:47.668
73f03686-ee9a-4579-b3bc-3303e354e180	ebc2d466-afd8-4c93-a009-c40784b51f9d	5	Tiêu chí số 53d	53d	\N	5.00	3	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:34:10.911625	2025-11-23 21:34:10.911625
5380bbd9-3b86-40ce-8597-2c87077ff5f8	8df81618-19da-478a-90c1-e9e2a15429c8	5	Tiêu chí số 54a	54a	\N	5.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:34:56.48932	2025-11-23 21:34:56.48932
d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	8df81618-19da-478a-90c1-e9e2a15429c8	5	Tiêu chí 54b	54b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:35:29.236802	2025-11-23 21:35:29.236802
726d7760-d6d8-4b9c-bc15-c751fd612610	7f73d34c-5a99-42ff-9c10-36e69d16e4a5	4	Tiêu chí số 55	55	\N	10.00	3	\N	55	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:36:29.760675	2025-11-23 21:36:29.760675
87dd917d-e936-49b5-8457-1a0b2ee49565	7f73d34c-5a99-42ff-9c10-36e69d16e4a5	4	Tiêu chí số 56	56	\N	10.00	3	\N	56	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:37:36.098973	2025-11-23 21:37:36.098973
b8801afc-9aa4-4700-abb9-b9878ee4ee7e	7f73d34c-5a99-42ff-9c10-36e69d16e4a5	4	Tiêu chí số 57	57	\N	15.00	0	\N	57	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:47:44.565873	2025-11-23 21:47:44.565873
28a278ee-0922-4b86-a091-a37a4a528448	7f73d34c-5a99-42ff-9c10-36e69d16e4a5	4	Tiêu chí số 58	58	\N	15.00	0	\N	58	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:48:10.362423	2025-11-23 21:48:10.362423
47e1c021-cef6-4889-baa9-d824d461da1d	b8801afc-9aa4-4700-abb9-b9878ee4ee7e	5	Tiêu chí số 57a	57a	\N	10.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:49:40.010411	2025-11-23 21:49:40.010411
d142142b-d819-4303-bdff-8d2c3a10e327	b8801afc-9aa4-4700-abb9-b9878ee4ee7e	5	Tiêu chí số 57b	57b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:50:10.063862	2025-11-23 21:50:10.063862
ad29789d-b8ad-4f31-a8ba-0df790b6d48e	28a278ee-0922-4b86-a091-a37a4a528448	5	Tiêu chí số 58a	58a	\N	10.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:51:00.972744	2025-11-23 21:51:00.972744
2161ca82-71b5-419f-bd3d-4a38216dca25	28a278ee-0922-4b86-a091-a37a4a528448	5	Tiêu chí số 58b	58b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:51:27.196079	2025-11-23 21:51:27.196079
7e3203dd-6fe2-47ad-bd33-a4746782eca2	19368a6c-671b-46da-9f6c-cfd234b537b6	3	Tiêu chí số 59	59	\N	10.00	2	\N	59	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:52:14.705469	2025-11-23 21:52:14.705469
712bccaa-5cb6-4eb1-be8e-304d5c700e3d	19368a6c-671b-46da-9f6c-cfd234b537b6	3	Tiêu chí số 60	60	\N	15.00	3	\N	60	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:54:02.991567	2025-11-23 21:54:02.991567
3bd5a661-dabb-42a3-b7bd-62baae50f6ed	19368a6c-671b-46da-9f6c-cfd234b537b6	3	Tiêu chí số 61	61	\N	5.00	2	\N	61	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:55:14.122191	2025-11-23 21:55:14.122191
dc47d96f-a72d-417b-a156-fc743e5e2f1a	19368a6c-671b-46da-9f6c-cfd234b537b6	3	Tiêu chí số 62	62	\N	10.00	3	\N	62	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:55:40.57712	2025-11-23 21:55:40.57712
5546bd4e-c045-4d52-8cd6-79408f8af1a3	b94bd25c-5f3e-43ea-98c5-11138b5095c3	3	Tiêu chí số 67	67	\N	10.00	3	\N	67	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 22:03:32.747158	2025-11-23 22:03:32.747158
a5719761-6a08-41c6-99be-e1b631c41975	b94bd25c-5f3e-43ea-98c5-11138b5095c3	3	Tiêu chí số 68	68	\N	5.00	3	\N	68	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 22:04:01.626889	2025-11-23 22:04:01.626889
edc3bf2f-4847-4758-81cf-6a0c84cda676	b94bd25c-5f3e-43ea-98c5-11138b5095c3	3	Tiêu chí số 69	69	\N	5.00	2	\N	69	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 22:05:02.074079	2025-11-23 22:05:02.074079
d555ced7-1211-4d31-8c05-cc44b14c20a1	ebc2d466-afd8-4c93-a009-c40784b51f9d	1	Tiêu chí số 53a	53a	\N	5.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:32:30.0111	2025-11-24 07:50:46.492
cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	b94bd25c-5f3e-43ea-98c5-11138b5095c3	1	Tiêu chí số 66	66	\N	5.00	3	\N	66	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 22:03:07.306716	2025-11-24 07:51:09.592
cdf9dfc9-a2db-4b12-8562-1009f500af78	b94bd25c-5f3e-43ea-98c5-11138b5095c3	1	Tiêu chí số 63	63	\N	5.00	2	\N	63	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:56:52.535256	2025-11-24 07:51:18.606
5b686276-91a2-43a8-a6fd-30e72c98f252	b94bd25c-5f3e-43ea-98c5-11138b5095c3	1	Tiêu chí số 64	64	\N	5.00	2	\N	64	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:59:07.144266	2025-11-24 07:51:23
0c7de719-6c75-4e5f-bead-03f772c73221	b94bd25c-5f3e-43ea-98c5-11138b5095c3	1	Tiêu chí số 65	65	\N	5.00	2	\N	65	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 22:02:37.23788	2025-11-24 07:51:27.72
319be6c1-eb00-41bc-8f80-48dd12d3d3dd	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 71	71	\N	1.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:51:47.271454	2025-11-24 10:51:47.271454
e823904a-7a2c-474e-895b-ba225efc6751	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 70	70	\N	2.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:51:08.693693	2025-11-24 10:51:08.693693
53dc5a74-fab1-4942-a54f-21a5f34b45ae	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 72	72	\N	1.50	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:52:10.112698	2025-11-24 10:52:10.112698
0dc41e0d-ef7f-43e7-b467-1678112877f9	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 73	73	\N	1.50	3	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:52:47.326152	2025-11-24 10:52:47.326152
eb30a3b6-ba28-4726-b0a5-43b238720619	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 74	74	\N	0.50	2	\N	5	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:55:58.742458	2025-11-24 10:55:58.742458
7e52a1dc-9d2b-4d67-9546-21017a044c8d	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 75	75	\N	0.50	2	\N	6	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:57:08.373459	2025-11-24 10:57:08.373459
3462ddf3-f516-4363-87f8-44d2ba92da64	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 76	76	\N	1.00	3	\N	7	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:58:24.593092	2025-11-24 10:58:24.593092
7244fa14-e0a5-4366-a31a-e136039445ba	6a09486e-7e01-4320-9746-949191f36502	3	Tiêu chí số 77	77	\N	2.00	3	\N	8	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:58:57.863377	2025-11-24 10:58:57.863377
dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	6fa1f4e3-a5e3-4439-9d35-a7234323aed6	4	Tiêu chí số 78	78	\N	2.00	2	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:00:16.42289	2025-11-24 11:00:16.42289
262d8859-2d57-4341-bba6-228f87871a4a	6fa1f4e3-a5e3-4439-9d35-a7234323aed6	4	Tiêu chí số 79	79	\N	2.00	2	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:00:53.847058	2025-11-24 11:00:53.847058
c2ca5e25-f355-48c5-963f-58f9abd5e319	6fa1f4e3-a5e3-4439-9d35-a7234323aed6	4	Tiêu chí số 80	80	\N	2.00	2	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:01:22.046627	2025-11-24 11:01:22.046627
432950d8-25a9-4726-b24f-6869f9c12c10	6fa1f4e3-a5e3-4439-9d35-a7234323aed6	4	Tiêu chí số 81	81	\N	4.00	3	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:02:03.673085	2025-11-24 11:02:03.673085
c490447c-6617-40d5-99a1-11e57139290a	59906472-16d5-41b3-a03c-ab016f580617	4	Tiêu chí số 91	91	\N	1.00	3	\N	10	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:07:41.029049	2025-11-24 11:07:41.029049
593c88af-c03f-43fa-b39c-69cfc510fc20	168f3175-150e-41ad-a12e-2bddbe7c6464	4	Tiêu chí số 92	92	\N	2.00	2	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:08:12.227502	2025-11-24 11:08:12.227502
420e7cc2-f2ba-4fe6-8351-730fb1e2b936	168f3175-150e-41ad-a12e-2bddbe7c6464	4	Tiêu chí số 93	93	\N	1.00	2	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:08:41.639209	2025-11-24 11:08:41.639209
88e5c0e3-6caf-4066-8851-e201c76e2ec1	168f3175-150e-41ad-a12e-2bddbe7c6464	4	Tiêu chí số 94	94	\N	1.00	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:09:16.784752	2025-11-24 11:09:16.784752
a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	168f3175-150e-41ad-a12e-2bddbe7c6464	4	Tiêu chí số 95	95	\N	1.00	3	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:09:42.866081	2025-11-24 11:09:42.866081
8b5eb951-a8f0-4e61-a3be-2f841d2ea6a9	3f6ec771-2eb2-49db-8ed1-34966a98fba9	2	Công tác hội và phong trào phụ nữ	1.e)	\N	5.00	0	\N	5	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:10:22.689682	2025-11-24 11:10:22.689682
e2a12005-4697-4566-91d8-fe76936856e3	8b5eb951-a8f0-4e61-a3be-2f841d2ea6a9	3	Tiêu chí số 96	96	\N	1.00	2	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:11:02.040382	2025-11-24 11:11:02.040382
97186d30-1727-43b3-bd5e-685ae3cc8f78	8b5eb951-a8f0-4e61-a3be-2f841d2ea6a9	3	Tiêu chí số 97	97	\N	1.00	2	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:11:51.198893	2025-11-24 11:11:51.198893
6a09486e-7e01-4320-9746-949191f36502	3f6ec771-2eb2-49db-8ed1-34966a98fba9	1	Công tác tuyên truyền, giáo dục	1.a)	\N	10.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:50:04.267994	2025-11-24 07:52:22.136
3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 82	82	\N	1.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:02:50.373917	2025-11-24 08:07:07.825
30ce5a37-830c-4e6f-9ab5-d108b2d856aa	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 83	83	\N	3.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:03:31.918758	2025-11-24 08:07:12.5
0d874a0f-1b7a-4004-8cda-1952c40f5928	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 84	84	\N	1.00	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:04:03.67611	2025-11-24 08:07:18.005
2e8a7134-2e2f-4b69-8bb8-3394cea840f5	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 85	85	\N	3.00	3	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:04:41.067045	2025-11-24 08:07:24.614
04d20169-ff00-42ad-b2a2-81f9adf94c2f	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 86	86	\N	1.00	3	\N	5	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:05:16.08982	2025-11-24 08:07:29.067
10392de9-00c3-4461-8c03-8b9df80b9dd1	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 87	87	\N	1.00	3	\N	6	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:05:48.488978	2025-11-24 08:07:34.85
91f0d26e-c70a-4522-ba08-2a38cf823fd0	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 88	88	\N	2.00	3	\N	7	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:06:16.278215	2025-11-24 08:07:39.507
b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 89	89	\N	1.00	3	\N	8	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:06:41.419297	2025-11-24 08:07:43.26
5da1d907-cb33-4043-b7d5-3a71d96afae6	8b5eb951-a8f0-4e61-a3be-2f841d2ea6a9	3	Tiêu chí số 98	98	\N	1.00	2	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:12:26.848677	2025-11-24 11:12:26.848677
24703ccc-61d6-4e27-9325-8dd505493afb	8b5eb951-a8f0-4e61-a3be-2f841d2ea6a9	3	Tiêu chí số 99	99	\N	1.00	3	\N	4	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:13:01.050587	2025-11-24 11:13:01.050587
017d894c-c894-454b-8957-25be9be88d40	8b5eb951-a8f0-4e61-a3be-2f841d2ea6a9	3	Tiêu chí số 100	100	\N	1.00	2	\N	5	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:13:23.967339	2025-11-24 11:13:23.967339
dafcf530-557a-44f1-af6e-7ca0a5647c4d	3f6ec771-2eb2-49db-8ed1-34966a98fba9	2	Chế độ thông tin, báo cáo	1.g)	\N	5.00	0	\N	6	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:14:02.3957	2025-11-24 11:14:02.3957
473fb095-1711-489f-8b16-6ff5aac4f1d5	dafcf530-557a-44f1-af6e-7ca0a5647c4d	3	Tiêu chí số 101	101	\N	5.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:14:40.847117	2025-11-24 11:14:40.847117
03f57b1f-7375-4f4d-bef7-4ad4ea04beac	f892532a-bfe8-4b15-a387-fb030a09b619	4	Tiêu chí số 102	102	\N	10.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:16:42.512215	2025-11-24 11:16:42.512215
4baf6310-700f-4a03-84e6-24d2efa70d69	f892532a-bfe8-4b15-a387-fb030a09b619	4	Tiêu chí số 103	103	\N	10.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:17:14.083403	2025-11-24 11:17:14.083403
b5e500c7-e88c-4922-84ba-8baec799d1b3	f892532a-bfe8-4b15-a387-fb030a09b619	4	Tiêu chí số 104	104	\N	10.00	3	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:17:43.688556	2025-11-24 11:17:43.688556
de48f1f4-c4ed-4006-9f14-52fca3d41042	7e9133e5-1f08-4af6-b82b-5591bb20c7e6	3	Việc thực hiện các nhiệm vụ chuyên đề hằng năm thuộc lĩnh vực công tác tổ chức, cán bộ 	2. b)	\N	10.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:19:01.328132	2025-11-24 11:19:01.328132
d38a02ec-2612-466e-9e40-dcbf8ec952bb	de48f1f4-c4ed-4006-9f14-52fca3d41042	4	Tiêu chí số 105	105	\N	10.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:19:29.822701	2025-11-24 11:19:29.822701
18ed267a-b058-4e1e-a987-47f3e97048d3	7e9133e5-1f08-4af6-b82b-5591bb20c7e6	3	Công tác xây dựng đảng về tổ chức và công tác đảng viên 	2.c)	\N	10.00	0	\N	3	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:20:10.09421	2025-11-24 11:20:10.09421
936d4b77-3c36-4008-97fe-7742a432e046	18ed267a-b058-4e1e-a987-47f3e97048d3	4	Tiêu chí số 106	106	\N	10.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:20:29.915799	2025-11-24 11:20:29.915799
b487f5d9-5e12-478d-8798-f6203a871885	b67a2844-951c-431c-94bd-f42e70980b68	1	Tiêu chí số 116	116	\N	1.00	3	\N	116	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:07:47.201163	2025-11-24 07:53:38.955
a48698a9-0d29-4e15-831a-97f0b17385ac	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 107	107	\N	1.00	2	\N	107	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:00:47.389296	2025-11-24 14:00:47.389296
c07e54b8-588b-41c1-bee9-c4aed0726511	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 108	108	\N	1.00	2	\N	108	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:01:30.989299	2025-11-24 14:01:30.989299
4caf250d-329f-4d8e-ae37-c88a914a153d	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 109	109	\N	1.00	2	\N	109	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:02:19.600018	2025-11-24 14:02:19.600018
b3f3e20d-6661-46e8-b58b-c974643c412c	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 110	110	\N	3.00	2	\N	110	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:02:49.924682	2025-11-24 14:02:49.924682
04fddf93-0005-43c2-bd35-ca2b965fe44b	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 111	111	\N	3.00	3	\N	111	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:03:21.192566	2025-11-24 14:03:21.192566
c8ca26c8-231d-4806-942a-afbb8a0d80c0	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 112	112	\N	1.00	2	\N	112	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:05:22.243862	2025-11-24 14:05:22.243862
7d9015f4-f8d0-4fe7-87a9-faf55a48b413	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 113	113	\N	2.00	3	\N	113	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:06:07.803227	2025-11-24 14:06:07.803227
a8585392-847e-4c9c-865d-0b79bbed54f0	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 114	114	\N	1.00	2	\N	114	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:06:38.702002	2025-11-24 14:06:38.702002
64744f6b-59e1-4590-a3ff-78b66b9a90a7	dc097788-6713-4864-a4a4-217c41560864	2	Tiêu chí số 115	115	\N	2.00	2	\N	115	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:07:13.307789	2025-11-24 14:07:13.307789
3e76bba7-f386-4124-ba55-3eea01d1a38f	b67a2844-951c-431c-94bd-f42e70980b68	1	Tiêu chí số 121	121	\N	1.00	3	\N	121	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:09:54.941137	2025-11-24 07:10:14.029
bcada071-a37b-4192-8c42-afdc522c3bf3	b67a2844-951c-431c-94bd-f42e70980b68	1	Tiêu chí số 122	122	\N	1.00	3	\N	122	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:11:38.96313	2025-11-24 07:11:58.298
bfbc3091-9661-482e-aa9b-4a9e4409cb6a	b67a2844-951c-431c-94bd-f42e70980b68	2	Tiêu chí số 123	123	\N	2.00	3	\N	123	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:12:21.89828	2025-11-24 14:12:21.89828
036c63d8-d0b1-412c-ac70-40bf5d359877	b67a2844-951c-431c-94bd-f42e70980b68	2	Tiêu chí số 124	124	\N	2.00	3	\N	124	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:12:50.756031	2025-11-24 14:12:50.756031
1418079e-67b7-465c-9ac3-b626ea3dfdbf	b67a2844-951c-431c-94bd-f42e70980b68	1	Tiêu chí số 117	117	\N	2.00	3	\N	117	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:08:17.791735	2025-11-24 07:53:44.706
90dc2f36-7803-4077-9ffa-c33881dba242	b67a2844-951c-431c-94bd-f42e70980b68	1	Tiêu chí số 118	118	\N	2.00	3	\N	118	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:08:56.161103	2025-11-24 07:53:50.466
c6a60793-756f-4526-8f3f-ed2f9b7703a4	b67a2844-951c-431c-94bd-f42e70980b68	1	Tiêu chí số 119	119	\N	2.00	3	\N	119	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:09:24.318699	2025-11-24 07:54:25.535
8f47dc3a-b639-4d09-acb9-4dbb9bde9859	7f6fb1db-9b08-4d08-96de-78ba68b1584c	3	Tiêu chí số 139	139	\N	2.00	3	\N	139	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:21:17.939792	2025-11-24 14:21:17.939792
e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 138	138	\N	3.00	3	\N	138	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:20:47.274924	2025-11-24 07:21:35.404
140368b6-7511-4d5c-a434-4fb50da9f877	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 137	137	\N	3.00	3	\N	137	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:20:21.360127	2025-11-24 07:21:50.903
fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	7f6fb1db-9b08-4d08-96de-78ba68b1584c	3	Tiêu chí số 140	140	\N	2.00	3	\N	140	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:22:30.557817	2025-11-24 14:22:30.557817
06d115ef-b738-4f1d-9a9c-9e8a0150def5	7698918c-dccc-4fff-b249-7db457c152e4	3	Tiêu chí số 141	141	\N	10.00	3	\N	141	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:24:04.391445	2025-11-24 14:24:04.391445
95ecadd0-d137-4bfc-b69b-12cf556a467c	7698918c-dccc-4fff-b249-7db457c152e4	3	Tiêu chí số 142	142	\N	10.00	3	\N	142	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:24:44.582414	2025-11-24 14:24:44.582414
992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	7698918c-dccc-4fff-b249-7db457c152e4	3	Tiêu chí số 143	143	\N	5.00	3	\N	143	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:25:57.169237	2025-11-24 14:25:57.169237
a88fb457-de23-41d1-a217-1516fc5557de	7698918c-dccc-4fff-b249-7db457c152e4	3	Tiêu chí số 144	144	\N	5.00	2	\N	144	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:26:31.20282	2025-11-24 14:26:31.20282
d016962d-b0c4-4e42-942f-9cad60ba440f	0b636667-762f-4835-b1d3-406b42d43ef7	3	Tiêu chí số 145	145	\N	5.00	3	\N	145	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:30:12.524571	2025-11-24 14:30:12.524571
48f4f6ff-2268-48e3-a3ae-c68d9d7af135	0b636667-762f-4835-b1d3-406b42d43ef7	3	Tiêu chí số 146	146	\N	10.00	0	\N	146	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:31:06.440659	2025-11-24 14:31:06.440659
bcfac4d1-207b-4978-b551-1719db9d7ae8	48f4f6ff-2268-48e3-a3ae-c68d9d7af135	4	Tiêu chí số 146b	146b	\N	5.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:32:07.213939	2025-11-24 14:32:07.213939
20d84ee4-ac0a-4365-ad68-83359862ae69	0b636667-762f-4835-b1d3-406b42d43ef7	3	Tiêu chí số 147	147	\N	15.00	3	\N	147	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:33:25.699601	2025-11-24 14:33:25.699601
d9d26ff4-1341-4c25-82e1-8ec562b829f9	0b636667-762f-4835-b1d3-406b42d43ef7	3	Tiêu chí số 148	148	\N	5.00	3	\N	148	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:33:56.245984	2025-11-24 14:33:56.245984
533ad720-b054-43ff-a802-368ec07ad8e5	0b636667-762f-4835-b1d3-406b42d43ef7	3	Tiêu chí số 149	149	\N	5.00	2	\N	149	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:36:23.781112	2025-11-24 14:36:23.781112
f8a1368d-2826-45ab-84a2-6e25a76a3a74	841834be-9133-47a0-8b4b-f49e53770d79	3	Tiêu chí số 150	150	\N	10.00	3	\N	150	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:37:13.279593	2025-11-24 14:37:13.279593
ef232bc9-a97d-46cf-b838-ea67e96b5271	841834be-9133-47a0-8b4b-f49e53770d79	3	Tiêu chí số 151	151	\N	10.00	3	\N	151	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:37:45.71857	2025-11-24 14:37:45.71857
29ca3068-2c31-4899-bd25-aa45f93abe93	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 125	125	\N	5.00	2	\N	125	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:13:39.674897	2025-11-24 07:58:31.356
dbfe7009-2130-49be-a36d-f80b4cc0dfe4	48f4f6ff-2268-48e3-a3ae-c68d9d7af135	1	Tiêu chí số 146a	146a	\N	5.00	3	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:31:28.856289	2025-11-24 09:45:18.09
c79e3144-f71f-49ed-92fb-421e459bf2af	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 127	127	\N	2.00	3	\N	127	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:15:04.182614	2025-11-24 07:58:42.691
1463af4f-223f-4146-ae23-9a326a61ad7e	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 128	128	\N	2.00	3	\N	128	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:15:22.925183	2025-11-24 07:58:53.314
04ebee63-5624-4a9f-9a69-7b519ddc2bef	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 129	129	\N	3.00	3	\N	129	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:15:51.057789	2025-11-24 07:59:00.599
f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 130	130	\N	1.50	3	\N	130	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:16:21.223622	2025-11-24 07:59:09.864
0797b27a-f581-418c-a1fd-4c85a8442591	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 131	131	\N	1.50	3	\N	131	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:16:45.906759	2025-11-24 07:59:18.663
12a78dac-7c82-4032-b61d-53b858b29b9d	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 132	132	\N	2.00	3	\N	132	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:17:11.51841	2025-11-24 07:59:25.343
b5927146-8aaf-4409-8142-3f4c11c4f2b4	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 133	133	\N	2.00	3	\N	133	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:17:33.258757	2025-11-24 07:59:31.607
78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 134	134	\N	2.00	3	\N	134	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:18:18.601843	2025-11-24 07:59:37.017
a6d07339-22c4-4da0-ab27-c3097e68cf5f	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 135	135	\N	2.00	3	\N	135	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:18:59.653273	2025-11-24 07:59:42.435
a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 136	136	\N	2.00	3	\N	136	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:19:46.764286	2025-11-24 07:59:46.164
46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	49a64260-903e-492a-8a56-ab78c434dae7	1	Tiêu chí số 152	152	\N	10.00	3	\N	152	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:38:21.859317	2025-11-24 08:00:21.007
0b636667-762f-4835-b1d3-406b42d43ef7	54a1fed9-2772-4472-aaaa-97becf2db886	1	Tổ chức phong trào thi đua	1.	\N	40.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:27:56.766008	2025-11-24 08:03:01.97
2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	7f6fb1db-9b08-4d08-96de-78ba68b1584c	1	Tiêu chí số 126	126	\N	5.00	2	\N	126	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:14:02.270134	2025-11-24 09:40:18.52
620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	49a64260-903e-492a-8a56-ab78c434dae7	1	Tiêu chí số 153	153	\N	5.00	3	\N	153	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:39:40.985543	2025-11-24 07:40:20.2
2c25c3bd-19b0-4aab-a99e-806e527815fe	59906472-16d5-41b3-a03c-ab016f580617	1	Tiêu chí số 90	90	\N	1.00	3	\N	9	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 11:07:12.108464	2025-11-24 07:46:06.941
f892532a-bfe8-4b15-a387-fb030a09b619	7e9133e5-1f08-4af6-b82b-5591bb20c7e6	1	Việc thực hiện các quy định về công tác tổ chức cán bộ; công tác xây dựng đảng về tổ chức và công tác đảng viên 	2.a)	\N	30.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 10:49:04.445233	2025-11-24 07:46:24.385
dc097788-6713-4864-a4a4-217c41560864	512d5d4a-cbf3-460e-9f74-a0b3bcca50ae	1	Công tác kiểm tra, giám sát, kỷ luật đảng	3.a)	\N	15.00	0	\N	1	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 13:57:26.916886	2025-11-24 07:46:48.332
db10be95-c13b-4487-b8d2-d03a5e784e69	417d134f-c87f-4f9b-853c-f249d86e512d	1	Tiêu chí số 41a	41a	\N	5.00	3	\N	0	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:01:05.137624	2025-11-24 07:49:43.44
f05a6cc8-a921-4f10-99f5-0b5afda37328	13e521c8-3e4d-40b3-9c93-9635b2784272	1	Tiêu chí số 49b	49b	\N	4.00	3	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-23 21:17:36.372448	2025-11-24 07:50:33.352
07132dd0-4bd5-4601-8a9b-6d05b87d354c	b67a2844-951c-431c-94bd-f42e70980b68	1	Tiêu chí số 120	120	\N	2.00	3	\N	120	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 14:55:10.778505	2025-11-24 07:55:28.069
b67a2844-951c-431c-94bd-f42e70980b68	512d5d4a-cbf3-460e-9f74-a0b3bcca50ae	1	Công tác thanh tra; tiếp công dân; giải quyết khiếu nại tố cáo, phòng chống tham nhũng	3. b)	\N	15.00	0	\N	2	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	1	2025-11-24 13:58:54.402838	2025-11-24 07:55:59.081
\.


--
-- Data for Name: criteria_bonus_penalty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.criteria_bonus_penalty (id, criteria_id, bonus_point, penalty_point, min_score, max_score, unit, created_at) FROM stdin;
\.


--
-- Data for Name: criteria_fixed_score; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.criteria_fixed_score (id, criteria_id, point_per_unit, max_score_limit, unit, created_at) FROM stdin;
\.


--
-- Data for Name: criteria_formula; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.criteria_formula (id, criteria_id, target_required, default_target, unit, created_at) FROM stdin;
\.


--
-- Data for Name: criteria_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.criteria_results (id, criteria_id, unit_id, period_id, actual_value, self_score, bonus_count, penalty_count, calculated_score, cluster_score, final_score, note, evidence_file, evidence_file_name, status, created_at, updated_at) FROM stdin;
8b43de22-a196-4c1a-9c01-d82a21d29774	d2e851bc-4408-4b55-9aeb-7a551d790f09	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	50.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:21.474358	2025-11-24 15:25:21.474358
57f5277b-773b-477e-be07-0af440e9944a	d2e851bc-4408-4b55-9aeb-7a551d790f09	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	50.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:22.265023	2025-11-24 15:25:22.265023
a48e036a-4f48-4b81-9e64-d76b43d51246	b8ee94cd-6988-47b8-8e43-67193def36b6	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:29.794421	2025-11-24 15:25:29.794421
61d01159-8d2b-4abd-8932-7c534d0caab2	d2e851bc-4408-4b55-9aeb-7a551d790f09	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	50.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:30.667178	2025-11-24 15:25:30.667178
449332f3-7d6d-4a02-ab36-0cf70e3454b4	f4bf6416-f972-4d4e-99e8-04a89fd369e2	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:35.473501	2025-11-24 15:25:35.473501
fff99c85-558e-4359-a50b-97e7af9c0530	1b32643f-336d-42af-bb06-99423ec5e622	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:40.113495	2025-11-24 15:25:40.113495
e809ac52-89d1-4620-8edc-e24b38c77b1e	b8ee94cd-6988-47b8-8e43-67193def36b6	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:43.946622	2025-11-24 15:25:43.946622
508b33fa-c3dc-4ab3-ae65-b1263acedec6	98b52742-77b5-4a61-a42c-ab4dba2c9474	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:45.53353	2025-11-24 15:25:45.53353
43cf8c08-71e7-4e82-88a7-4f650d5a026c	0665d813-c605-4a69-956f-245763cd28e9	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:54.856663	2025-11-24 15:25:54.856663
ece356b0-b674-4abf-aa80-7e1077841ecb	ab174e0f-5d07-4ee0-80de-58e952cfacfa	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:25:58.74479	2025-11-24 15:25:58.74479
060e554f-9060-4453-b20e-88fbdf1cc40c	381a96ff-c413-4412-8b19-3c0117aea3ec	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	20.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:26:18.674726	2025-11-24 15:26:18.674726
182cb2c6-f99d-4a13-854e-1a0ba7cdb2d0	cc239035-3c1b-41b2-a71a-2a43f5728543	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:26:37.432535	2025-11-24 15:26:37.432535
065d1538-3a0f-4bd7-8ed6-c33c2ff9ddb4	7313230c-811c-45e7-ba72-bc8ebcd65f7a	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:26:49.945287	2025-11-24 15:26:49.945287
f168531e-1a9b-4ded-9117-70bf95ad887c	f4bf6416-f972-4d4e-99e8-04a89fd369e2	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:26:52.744262	2025-11-24 15:26:52.744262
f3d61eda-1e1e-4e66-aa48-dc5e67a0e50f	d32ec9db-b64f-42c7-a21e-16a443599cf5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:26:54.297243	2025-11-24 15:26:54.297243
085a6c64-21f7-4ba4-81de-87dc9f2a69ab	1b32643f-336d-42af-bb06-99423ec5e622	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:02.226636	2025-11-24 15:27:02.226636
ccbe50a0-6bed-4b78-842c-15d9067791ad	98b52742-77b5-4a61-a42c-ab4dba2c9474	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:08.422301	2025-11-24 15:27:08.422301
f8ec9174-7d0a-4814-acf1-2a8818b98d5d	ef8f8ad5-2255-4292-a371-a681701526bc	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:09.12919	2025-11-24 08:27:14.515
ce48d1ef-0c6d-4924-beae-7567db2c9628	0665d813-c605-4a69-956f-245763cd28e9	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:23.241424	2025-11-24 15:27:23.241424
81ba49da-279f-4097-abb5-6a9351256e49	ab174e0f-5d07-4ee0-80de-58e952cfacfa	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:30.066796	2025-11-24 15:27:30.066796
3a554235-0bee-41ac-8616-ffcef18730ea	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:50.230051	2025-11-24 15:27:50.230051
03e20c21-1dbe-46be-9547-3d54dd7bb76c	381a96ff-c413-4412-8b19-3c0117aea3ec	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	20.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:54.472972	2025-11-24 15:27:54.472972
c54fb8b1-7fb9-4a24-b788-2a67c3b97ec2	8c181441-36a7-432a-a2de-2026909f9a41	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:27:55.989964	2025-11-24 15:27:55.989964
43498601-428a-47b3-9ca4-71d4a4e2266f	2727281f-30a6-451a-8aa7-adf9d33434af	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:03.20167	2025-11-24 15:28:03.20167
f7d433bf-02cc-4c39-b61f-68c22e994ef9	b8ee94cd-6988-47b8-8e43-67193def36b6	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:04.050445	2025-11-24 15:28:04.050445
00ad16b7-6b1c-4d44-a4d6-e2e2d6ff82a7	02507c7a-6a42-4bdc-a8b8-79cc07d58eac	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:09.745195	2025-11-24 15:28:09.745195
1031a931-819d-43a8-af79-7a0820d4ff3e	cc239035-3c1b-41b2-a71a-2a43f5728543	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:16.873471	2025-11-24 15:28:16.873471
479103b7-2369-4c1b-9a63-666da3f1c85f	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:19.402961	2025-11-24 15:28:19.402961
76218163-c46b-4319-9d76-084bc4672286	d574da97-c404-48bc-8ddb-1d0dd6943d04	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:27.636701	2025-11-24 15:28:27.636701
bf09d7d1-ec8b-4a7c-8cea-21e2325284d4	7313230c-811c-45e7-ba72-bc8ebcd65f7a	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:29.635016	2025-11-24 15:28:29.635016
a716313b-58ad-4d57-b80b-bad8eaae8201	fa96f655-905e-4a20-b489-8c8d3295ec83	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:34.688342	2025-11-24 15:28:34.688342
5eb84507-c970-442c-817b-0d859fa3c91e	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:40.557241	2025-11-24 15:28:40.557241
709a9a2b-69fa-4723-bf26-c265c4cda440	d32ec9db-b64f-42c7-a21e-16a443599cf5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:40.856778	2025-11-24 15:28:40.856778
0567817a-04b6-4d90-8b5c-8714fc5c8d5d	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:49.034088	2025-11-24 15:28:49.034088
97b290d4-9370-4020-a36f-c111b4e3d5e3	87605a36-1a09-42c9-8362-ee3f79925b46	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:54.419894	2025-11-24 15:28:54.419894
1dd4507a-dc67-46e4-bfc6-656578f85416	ef8f8ad5-2255-4292-a371-a681701526bc	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:28:55.219452	2025-11-24 15:28:55.219452
2669184c-f37b-4f57-a80b-51c0104a7bc6	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:29:02.442437	2025-11-24 15:29:02.442437
625aa34c-46a4-42f9-92bf-6a2d01b61fc9	8c181441-36a7-432a-a2de-2026909f9a41	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:29:07.017633	2025-11-24 15:29:07.017633
9b872b94-6b0b-4fe4-8a4f-74a8655dfc0f	2727281f-30a6-451a-8aa7-adf9d33434af	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:29:13.915651	2025-11-24 15:29:13.915651
a94d7a65-dedf-4cc5-b20a-9590cce6a187	02507c7a-6a42-4bdc-a8b8-79cc07d58eac	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:29:35.520876	2025-11-24 15:29:35.520876
b30c30a5-031d-4696-ac5d-30d0e25814d4	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:29:40.191345	2025-11-24 15:29:40.191345
a58e00d3-6e73-4947-ac34-5d6333349af1	d574da97-c404-48bc-8ddb-1d0dd6943d04	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:29:45.022673	2025-11-24 15:29:45.022673
bbe08079-c8e3-429c-aa03-55bfcae805f3	fa96f655-905e-4a20-b489-8c8d3295ec83	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:29:48.190694	2025-11-24 15:29:48.190694
039ce1b4-8c10-4791-968e-4ba2f4a90079	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:30:01.122545	2025-11-24 15:30:01.122545
8399abb0-898d-47df-96c2-f48d6b29c0c6	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:30:11.176049	2025-11-24 15:30:11.176049
6c1d40bf-72c3-4518-abae-958ad6274439	87605a36-1a09-42c9-8362-ee3f79925b46	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:30:21.190183	2025-11-24 15:30:21.190183
8d8de68a-67fe-4935-b234-1582332c53d5	a4f478bf-d50d-4fe6-a339-de512cbbab8b	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:32:00.493655	2025-11-24 15:32:00.493655
a6781f5a-2a8f-4fb0-95da-bf9a188a4242	9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:32:05.309981	2025-11-24 15:32:05.309981
5470ef3b-2acb-4a39-a70a-301e5e671945	a4f478bf-d50d-4fe6-a339-de512cbbab8b	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:32:25.921177	2025-11-24 15:32:25.921177
762f23c0-a5c4-4eb6-8c2a-3752ad7c04d4	9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:32:29.833778	2025-11-24 15:32:29.833778
8bd9222f-5641-4138-a900-b79224d27ea9	5620079f-e61f-4e50-8571-a5c2dd9de71e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 15:30:49.500464	2025-11-25 01:03:07.415
3b3199f3-12a3-4e0a-a442-7a4160279c86	c981c60d-9dec-44ef-bbba-5973de4977b2	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:34:38.197172	2025-11-24 15:34:38.197172
b451f6a2-acfe-42e1-9b30-d0a2d6bdb534	267e5cb1-334e-4830-beb1-d94707b486bb	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:34:46.744229	2025-11-24 15:34:46.744229
0674ae0c-a053-4a02-99f1-49cba416abb2	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	2.50	0	0	\N	2.50	2.50	\N	\N	\N	draft	2025-11-24 15:31:26.572762	2025-11-25 01:03:07.42
fc25ccc2-8314-4242-a585-9f5479d20639	309b57b1-e23c-41c0-9d69-175782810453	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	66.67	20.00	0	0	\N	16.49	16.49	\N	\N	\N	draft	2025-11-24 15:31:37.391897	2025-11-25 01:03:07.423
ad32e9ed-c5d1-4c83-84b7-8d4b34820cdb	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:30:16.402721	2025-11-25 01:03:07.419
ad3c1cc8-e7cc-4c9b-ab28-483d2e6ef604	309b57b1-e23c-41c0-9d69-175782810453	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:32:03.880427	2025-11-25 01:03:07.424
1b5ea557-2729-4c58-b1eb-0c0b28700170	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 15:31:54.015849	2025-11-25 01:03:07.43
eb80017a-81ea-4cc8-a763-9808281d7daf	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 15:32:20.783766	2025-11-25 01:03:07.431
a3fa7c1f-94bb-4969-b3c1-1750f0885659	60087a36-e314-4fc1-b4d7-9aa1a33e4109	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	5.00	0	0	\N	5.00	5.00	\N	\N	\N	draft	2025-11-24 15:32:16.761632	2025-11-25 01:03:07.434
87e74e1d-cf86-4cf6-aa78-7e5134c08e98	60087a36-e314-4fc1-b4d7-9aa1a33e4109	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:32:43.191079	2025-11-25 01:03:07.434
31d3d7d2-6be5-4ac7-8dc1-4b06212022db	600a025b-0c42-4f27-9475-0316676f584c	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:32:51.403836	2025-11-25 01:03:07.437
4860b5f4-cf7d-4901-9ee1-e80302bc4363	600a025b-0c42-4f27-9475-0316676f584c	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	5.00	0	0	\N	5.00	5.00	\N	\N	\N	draft	2025-11-24 15:33:43.953214	2025-11-25 01:03:07.437
1c9a4024-40c8-4a24-902a-bca9814dfcf9	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:33:01.685785	2025-11-25 01:03:07.44
6b9f6461-4972-4797-afb5-df65bb2c6da9	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:34:16.502577	2025-11-25 01:03:07.441
b07c7398-5f2d-4871-ba34-d91bbadc333c	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:33:40.168026	2025-11-25 01:03:07.443
d69cce52-0981-4ac9-8795-76c007d16ab4	4b68575e-b415-45b1-9338-b43937cb7a76	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:34:13.959658	2025-11-25 01:03:07.447
34a0539e-f678-4daf-a5d4-ccc20064c2ec	c684de0e-7f27-4e91-87a3-4f5ae46156bc	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	5.00	5.00	0	0	\N	3.41	3.41	\N	\N	\N	draft	2025-11-24 15:34:30.871947	2025-11-25 01:03:07.45
8d9e6bfe-097f-41c2-adbd-d78a29240865	5620079f-e61f-4e50-8571-a5c2dd9de71e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 15:29:47.059903	2025-11-25 01:03:07.414
f48edcb1-a55b-4e43-93bd-bedd5542b581	d2e851bc-4408-4b55-9aeb-7a551d790f09	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	50.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:35:00.169622	2025-11-24 15:35:00.169622
2430415f-ac9f-48bd-b09c-350b40b5b58c	b8ee94cd-6988-47b8-8e43-67193def36b6	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:35:16.584155	2025-11-24 15:35:16.584155
1fde670c-67fe-4f42-996a-f680f38fcc68	7112a886-e9b0-4e40-80ef-a73f9cba962e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:35:17.742565	2025-11-24 15:35:17.742565
c6a99cdd-e7ba-4085-8e6b-8f995e458eb0	f4bf6416-f972-4d4e-99e8-04a89fd369e2	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:35:42.437514	2025-11-24 15:35:42.437514
fb7299ec-97c9-4fd7-8e28-9f5ea1d5b986	1b32643f-336d-42af-bb06-99423ec5e622	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:35:51.399392	2025-11-24 15:35:51.399392
232d6ac6-484f-417e-b5f8-293c0f78c294	c981c60d-9dec-44ef-bbba-5973de4977b2	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:35:51.858945	2025-11-24 15:35:51.858945
0f43365e-0634-4099-ac05-d4f1cb991779	267e5cb1-334e-4830-beb1-d94707b486bb	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:35:59.020029	2025-11-24 15:35:59.020029
37aa5120-28ac-4f5b-9d19-31ca9ac8c4e9	98b52742-77b5-4a61-a42c-ab4dba2c9474	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:07.288283	2025-11-24 15:36:07.288283
9e5e3923-305e-4ca2-b18c-d7d6b71071d1	0665d813-c605-4a69-956f-245763cd28e9	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:18.397066	2025-11-24 15:36:18.397066
cc33c79c-44a4-4fe0-92fb-10a177abdad5	ab174e0f-5d07-4ee0-80de-58e952cfacfa	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:23.005369	2025-11-24 15:36:23.005369
35850d6a-3e2f-44d2-95ef-3ba231c69be6	7112a886-e9b0-4e40-80ef-a73f9cba962e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:30.832962	2025-11-24 15:36:30.832962
381ca537-ede7-45fa-9b90-fed2c30e641d	381a96ff-c413-4412-8b19-3c0117aea3ec	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	20.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:32.915357	2025-11-24 15:36:32.915357
ed043492-0b27-4261-ba5e-282f521a5161	be878744-4347-47da-9a82-7a1dde8a1077	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:42.848759	2025-11-24 15:36:42.848759
6e3def29-8a75-4aa5-8d35-94d23317ded7	be878744-4347-47da-9a82-7a1dde8a1077	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:52.480554	2025-11-24 15:36:52.480554
165ccdae-5ed9-4dfd-9a59-5b3161db5d06	cc239035-3c1b-41b2-a71a-2a43f5728543	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:36:55.1933	2025-11-24 15:36:55.1933
eea6d25f-2dfd-4e16-a974-e5c0118f82ea	7313230c-811c-45e7-ba72-bc8ebcd65f7a	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:01.22661	2025-11-24 15:37:01.22661
44e5ec05-e7e1-4f2a-86f4-dc940e248d4b	d9337788-d07b-487e-a8ea-79bd9a237706	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:03.867286	2025-11-24 15:37:03.867286
1aeb6af9-2143-4b48-8f48-20f124a50611	d9337788-d07b-487e-a8ea-79bd9a237706	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:04.978838	2025-11-24 15:37:04.978838
554b07b2-c655-4e10-a31d-2647a4336b39	d32ec9db-b64f-42c7-a21e-16a443599cf5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:06.54733	2025-11-24 15:37:06.54733
edc4aaca-ef76-4862-b742-1287064bf7e4	ef8f8ad5-2255-4292-a371-a681701526bc	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:10.37871	2025-11-24 15:37:10.37871
5b32a97a-39ca-4d35-8631-17322e3acfeb	8a5ebc3d-20ee-4780-b286-64c434c87a72	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:18.839918	2025-11-24 15:37:18.839918
f024ef2e-b3fc-42d7-9bd4-80065174299b	eb7bd701-5795-43cc-8391-21426990fbb5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:26.285609	2025-11-24 15:37:26.285609
4d205911-7fcb-47dc-b153-9fbacfa756e5	d1635049-c122-4492-9597-7e125fcf09f8	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:33.682403	2025-11-24 15:37:33.682403
2694ade8-59fa-4060-9c47-d63e9ca5e637	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:48.713853	2025-11-24 15:37:48.713853
55b62ef1-bf08-4807-826d-44e48939473f	8a5ebc3d-20ee-4780-b286-64c434c87a72	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:08.160178	2025-11-24 08:37:51.851
b22b3623-7f63-4474-807e-132912bf3b36	eb7bd701-5795-43cc-8391-21426990fbb5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:37:59.827498	2025-11-24 15:37:59.827498
9eef797c-357d-4646-ba06-e1f12356d33f	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:38:46.793947	2025-11-24 15:38:46.793947
cfe57a33-812c-42fb-82dd-65e6c284ef6f	8c181441-36a7-432a-a2de-2026909f9a41	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:38:49.858699	2025-11-24 15:38:49.858699
c2961392-382d-428e-8ef1-c620d8a7ce79	c684de0e-7f27-4e91-87a3-4f5ae46156bc	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	2.50	0	0	\N	2.50	2.50	\N	\N	\N	draft	2025-11-24 15:35:41.167294	2025-11-25 01:03:07.451
45620183-3950-4821-801a-ec2655ac813c	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	5.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 15:35:00.986734	2025-11-25 01:03:07.453
b4ef1165-b046-408b-b7f2-2005efdadf40	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:36:09.919655	2025-11-25 01:03:07.454
76ac8081-593d-463f-b84b-d692053f76b5	165aae17-5f5b-476e-bd69-05c16e9e4c24	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	8.00	7.50	0	0	\N	7.50	7.50	\N	\N	\N	draft	2025-11-24 15:35:10.755905	2025-11-25 01:03:07.456
00a2936b-09dc-4f62-8d26-966805d1b07d	165aae17-5f5b-476e-bd69-05c16e9e4c24	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:36:22.882915	2025-11-25 01:03:07.457
055bd6ea-83d5-44f5-85d0-35af86dff731	4b68575e-b415-45b1-9338-b43937cb7a76	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:35:30.989872	2025-11-25 01:03:07.447
81b9caae-cbed-46f4-ba30-775f330ad5f0	2727281f-30a6-451a-8aa7-adf9d33434af	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:38:55.571757	2025-11-24 15:38:55.571757
4d1fdba8-4835-42cb-a8c7-3bb3200f668a	d1635049-c122-4492-9597-7e125fcf09f8	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:39:00.179875	2025-11-24 15:39:00.179875
cedbd40f-58d5-4e80-9321-535f2cc1344c	02507c7a-6a42-4bdc-a8b8-79cc07d58eac	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:39:13.070123	2025-11-24 15:39:13.070123
7c2f32e4-ca63-4104-b2e1-abf9cb41ce07	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:39:25.885868	2025-11-24 15:39:25.885868
48d39eda-5f0e-4c49-931f-9706704b12c4	d574da97-c404-48bc-8ddb-1d0dd6943d04	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:39:39.323986	2025-11-24 15:39:39.323986
42428318-25d1-4161-a6e2-88ff5fed7bed	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:39:55.835092	2025-11-24 15:39:55.835092
571266ff-210f-48d0-90e3-87c3cb1784d3	246965b3-e65a-48f9-9f68-fdda80be8169	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:01.657079	2025-11-24 15:40:01.657079
7203aecd-e364-45d1-a263-8332bc573eb8	db10be95-c13b-4487-b8d2-d03a5e784e69	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:09.510565	2025-11-24 15:40:09.510565
0fcd295c-66ab-40ee-a99e-0663a0e0b661	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.77	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:18.83835	2025-11-24 15:40:18.83835
a69777c3-bebd-4925-b86c-3b38c9347df3	db9717f5-c7a7-4532-97b1-e33f0ec86750	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:22.907223	2025-11-24 15:40:22.907223
edef7c77-467e-403f-add6-60bd51c1357c	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:39:58.392253	2025-11-24 08:40:24.67
abc3d38d-9a63-41d8-9b1b-276e0ea21941	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:26.016645	2025-11-24 15:40:26.016645
5c451d5a-013a-4518-8259-e375da30848f	750d4861-d84c-4622-a0f5-e709289e603b	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:33.51458	2025-11-24 15:40:33.51458
8ca99af8-63d1-4417-8e69-c9a228f215e9	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:37.932034	2025-11-24 15:40:37.932034
158a1932-4da7-4a25-ad96-b521dc4ff13a	97ee726a-f9c6-4c65-9794-543a6feb7a1b	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:42.354246	2025-11-24 15:40:42.354246
d37018b4-f449-46c2-8b8a-0195ec571ff7	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:46.019009	2025-11-24 15:40:46.019009
7d3ce3d3-f510-4815-889b-a5f2a379f1e8	1f752b6d-e8ff-4061-97f6-310f6fa0664b	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:49.885405	2025-11-24 15:40:49.885405
6b4ab590-c8f6-48ed-97c2-a41f9b81dc60	973abd8b-5798-4c77-912f-2f036e0e2d28	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:54.556141	2025-11-24 15:40:54.556141
32cd48e6-673d-47d8-9087-8d680fb63496	246965b3-e65a-48f9-9f68-fdda80be8169	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:40:56.599933	2025-11-24 15:40:56.599933
d4ed4b77-bb24-478f-95f1-5d7f7a426c28	a03680b8-7258-4d8f-95dc-29aaba658479	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:01.038145	2025-11-24 15:41:01.038145
903bad0e-2f7f-4ac2-a6a2-5cfc241e509d	db10be95-c13b-4487-b8d2-d03a5e784e69	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:06.778823	2025-11-24 15:41:06.778823
c69b843c-c0a7-45b0-a4fc-9e0e3a13a02b	4ee3df5c-a054-4b93-9f97-52a99196cdfe	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:07.858386	2025-11-24 15:41:07.858386
725bbcb3-4528-4b76-a24c-dbf2e7a47929	db9717f5-c7a7-4532-97b1-e33f0ec86750	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:11.009257	2025-11-24 15:41:11.009257
3a519945-7c15-4912-b435-571663a4e4b3	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:15.759871	2025-11-24 15:41:15.759871
cd080b76-05f5-4744-a1d1-a57627151375	750d4861-d84c-4622-a0f5-e709289e603b	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:19.789503	2025-11-24 15:41:19.789503
6e890319-6648-4c55-b357-2811f8b1f090	97ee726a-f9c6-4c65-9794-543a6feb7a1b	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:27.051621	2025-11-24 15:41:27.051621
05c4d30a-b72a-4ef3-bb7e-64d44debffd4	1f752b6d-e8ff-4061-97f6-310f6fa0664b	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:32.231637	2025-11-24 15:41:32.231637
2099413c-20e1-46d3-b7ce-6175e0979538	23db48b5-e04d-4351-b095-bdf2defff0c4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:36.098871	2025-11-24 15:41:36.098871
6d008991-64f3-49dd-84de-c7fd2a4803da	973abd8b-5798-4c77-912f-2f036e0e2d28	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:40.333928	2025-11-24 15:41:40.333928
648d871a-2447-4cee-8e01-05245e8039d5	a03680b8-7258-4d8f-95dc-29aaba658479	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:45.945588	2025-11-24 15:41:45.945588
d2528651-ee9f-46cf-807d-7b898d9825ab	4ee3df5c-a054-4b93-9f97-52a99196cdfe	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:50.640589	2025-11-24 15:41:50.640589
06ddf6d2-36ff-46a8-91fa-44dd64479049	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:57.980189	2025-11-24 15:41:57.980189
f911e6cc-192c-4d61-8d51-1f0ba0262f25	23db48b5-e04d-4351-b095-bdf2defff0c4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:41:59.677602	2025-11-24 15:41:59.677602
3d9ac609-c304-45a6-a2d5-6340dfe0ed27	f05a6cc8-a921-4f10-99f5-0b5afda37328	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:04.68395	2025-11-24 15:42:04.68395
3fc78f6f-66fd-453a-840e-e4cddbb1fda3	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:09.083027	2025-11-24 15:42:09.083027
aa78b0a2-077b-427a-b2bc-8379f1f53e1b	18aaf397-5d9c-42f9-a327-fa0fba8d477d	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:12.133939	2025-11-24 15:42:12.133939
b4330d10-fc6b-4c10-9efd-74e7925e46f0	c869685a-fd7e-46ed-8af6-9d8c6b74f9de	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:16.497312	2025-11-24 15:42:16.497312
dc368376-c059-40f5-8cb1-42435f215567	f05a6cc8-a921-4f10-99f5-0b5afda37328	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:21.978921	2025-11-24 15:42:21.978921
ade21cbb-c1ac-455d-9350-3d0e6e5d1421	884e9fae-75d3-483c-b444-a464ac0130b9	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:24.396038	2025-11-24 15:42:24.396038
746400ae-9b41-4c0e-9f03-56aeb91033b1	ffe4c55a-155d-409f-ad66-49ed6be0ded7	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:28.833252	2025-11-24 15:42:28.833252
1faada7d-3ac8-4f21-8b6e-7880c45d6936	18aaf397-5d9c-42f9-a327-fa0fba8d477d	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:31.003062	2025-11-24 15:42:31.003062
87e8d8a6-d44f-4520-8d1e-401eff5dd66a	485d3228-8245-454e-bc68-f2ce6c944263	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:34.6838	2025-11-24 15:42:34.6838
ac7935c5-23b9-4004-8fa1-29da75d083dc	94b798d5-13b9-49ad-9d22-228a3f07bfb5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:43.549906	2025-11-24 15:42:43.549906
cfa1f835-a47e-46d9-b55d-6388b96f99b4	d555ced7-1211-4d31-8c05-cc44b14c20a1	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:43:09.521216	2025-11-24 15:43:09.521216
f7356196-5e22-4aec-b681-93ab3e9b6b93	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:43:16.397831	2025-11-24 15:43:16.397831
8dc29176-d52f-4e15-94ef-8769b7cda280	fa96f655-905e-4a20-b489-8c8d3295ec83	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:43:22.849575	2025-11-24 15:43:22.849575
e8051de4-1ca6-4305-84e5-8f68c2cbb1f6	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:43:27.76279	2025-11-24 15:43:27.76279
acc91564-8971-4dd8-b3f7-331a5ece9b77	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:43:34.558342	2025-11-24 15:43:34.558342
83b55c68-1b58-4e08-8c35-819e50d5597c	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:43:45.519793	2025-11-24 15:43:45.519793
a4ea7777-39ba-4e10-b7c9-04d37f537083	87605a36-1a09-42c9-8362-ee3f79925b46	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:43:56.105036	2025-11-24 15:43:56.105036
afc0f3b7-20bc-4bb7-abd4-405e790f94a6	73f03686-ee9a-4579-b3bc-3303e354e180	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:00.917408	2025-11-24 15:44:00.917408
778b48b2-624c-4d2a-910a-9eac31b60e56	5380bbd9-3b86-40ce-8597-2c87077ff5f8	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:06.849139	2025-11-24 15:44:06.849139
1b4f4662-d897-4399-a3b9-010097a7566f	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:18.393408	2025-11-24 15:44:18.393408
65649f44-aa6c-4e34-9849-e61433d89e56	726d7760-d6d8-4b9c-bc15-c751fd612610	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:27.130054	2025-11-24 15:44:27.130054
23c79b5a-d213-4897-b62d-b5e22ae257be	87dd917d-e936-49b5-8457-1a0b2ee49565	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:32.799895	2025-11-24 15:44:32.799895
107e3c1b-65a7-4f19-ad2d-e6d954580a8f	47e1c021-cef6-4889-baa9-d824d461da1d	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:42.458925	2025-11-24 15:44:42.458925
09acea53-917c-4516-b976-9e093e33c3fc	d142142b-d819-4303-bdff-8d2c3a10e327	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:50.854277	2025-11-24 15:44:50.854277
90fb26be-5384-4282-85ff-62d7aaac8ce8	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:44:58.078149	2025-11-24 15:44:58.078149
dc204573-48de-4a0d-aadd-c71c95bf1b1f	2161ca82-71b5-419f-bd3d-4a38216dca25	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:07.3365	2025-11-24 15:45:07.3365
9c51d49e-4623-457c-8e14-dc21d2d35a33	7e3203dd-6fe2-47ad-bd33-a4746782eca2	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:13.619188	2025-11-24 15:45:13.619188
f1598a68-e6a4-4e37-8d7f-47bcbe5fc35c	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	15.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:24.734625	2025-11-24 15:45:24.734625
3e5d945c-0204-4851-9bc2-3ac669e496ec	3bd5a661-dabb-42a3-b7bd-62baae50f6ed	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:31.007571	2025-11-24 15:45:31.007571
b1b7fd9a-b745-45b6-8475-0bca99564b59	dc47d96f-a72d-417b-a156-fc743e5e2f1a	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:36.757189	2025-11-24 15:45:36.757189
a0911011-7e68-4bc2-ab78-f385e0f8ebda	cdf9dfc9-a2db-4b12-8562-1009f500af78	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:46.778554	2025-11-24 15:45:46.778554
e9f1e7c6-e29e-4e7e-aae1-b3faf8e2856e	5b686276-91a2-43a8-a6fd-30e72c98f252	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:54.551352	2025-11-24 15:45:54.551352
26ee5523-dbe9-4d83-99f3-50792fb2d71d	0c7de719-6c75-4e5f-bead-03f772c73221	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:45:59.443257	2025-11-24 15:45:59.443257
f5808b9a-9a9a-4b00-b8e5-c1970214a1c2	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:06.351754	2025-11-24 15:46:06.351754
0c9b87a2-d3b0-4d46-83b6-72fa6744f2ea	5620079f-e61f-4e50-8571-a5c2dd9de71e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 15:44:56.609552	2025-11-25 01:03:07.416
f36c0c30-0390-4c19-b556-a550fd902362	5546bd4e-c045-4d52-8cd6-79408f8af1a3	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:17.03705	2025-11-24 15:46:17.03705
f7c95ede-41be-4a91-a63c-198b5a3706db	a5719761-6a08-41c6-99be-e1b631c41975	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:22.546216	2025-11-24 15:46:22.546216
cf5578a8-9e45-4293-b235-2d808edc55b8	edc3bf2f-4847-4758-81cf-6a0c84cda676	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:33.618561	2025-11-24 15:46:33.618561
936ac58b-f7b1-4477-b859-e083b0c47546	e823904a-7a2c-474e-895b-ba225efc6751	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:40.927473	2025-11-24 08:46:43.984
f3e8d86d-5563-4ddc-bdad-cbda7ffc3faf	c869685a-fd7e-46ed-8af6-9d8c6b74f9de	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:42:39.520126	2025-11-24 08:46:49.167
0bb7e84f-942b-4215-8f17-0c54121f4d69	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:50.594424	2025-11-24 15:46:50.594424
e551dcee-cee0-458f-8a80-8f55fd88442e	884e9fae-75d3-483c-b444-a464ac0130b9	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:57.78431	2025-11-24 15:46:57.78431
1dcee508-db67-4d1d-a193-2b9283a316d6	ffe4c55a-155d-409f-ad66-49ed6be0ded7	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:00.926401	2025-11-24 15:47:00.926401
dccc5a69-c4c0-46b0-9846-5cc4bb7647a9	485d3228-8245-454e-bc68-f2ce6c944263	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:06.853759	2025-11-24 15:47:06.853759
87c52bb7-b813-44b0-bb41-8ee2c09c9f14	53dc5a74-fab1-4942-a54f-21a5f34b45ae	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.25	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:46:56.773007	2025-11-24 08:47:09.089
0cc57e84-8fad-4523-ba80-c1c9ccbf6072	94b798d5-13b9-49ad-9d22-228a3f07bfb5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:14.201329	2025-11-24 15:47:14.201329
1ec5cb46-02f2-41f6-8146-f334eae55ede	d555ced7-1211-4d31-8c05-cc44b14c20a1	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:20.267449	2025-11-24 15:47:20.267449
f63642e7-c8c1-4fbe-b094-054b49b07aba	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:24.102335	2025-11-24 15:47:24.102335
a6c35fa3-38ff-47da-b926-c5310d21d042	0dc41e0d-ef7f-43e7-b467-1678112877f9	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:26.206875	2025-11-24 15:47:26.206875
4a14ab13-6f46-4d48-98ae-366affed3e43	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:28.260954	2025-11-24 15:47:28.260954
3d14a405-44e6-40b1-82e1-3408f6371b4f	eb30a3b6-ba28-4726-b0a5-43b238720619	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:47:33.19719	2025-11-24 15:47:33.19719
6e2fb2d0-5392-4c37-b020-ae61a1293aae	73f03686-ee9a-4579-b3bc-3303e354e180	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:36.663062	2025-11-24 15:47:36.663062
4d8d6d95-4b2c-42fe-ae8e-1bf5f7c0f780	5380bbd9-3b86-40ce-8597-2c87077ff5f8	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:41.141085	2025-11-24 15:47:41.141085
bc3952da-c743-4588-b81a-bdab6153b8dd	7e52a1dc-9d2b-4d67-9546-21017a044c8d	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:41.953973	2025-11-24 15:47:41.953973
919e34d7-b5e6-48c3-a231-833e54bcca78	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:45.642183	2025-11-24 15:47:45.642183
47e764ae-732c-452b-a1f4-5b07e52c6179	726d7760-d6d8-4b9c-bc15-c751fd612610	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:50.982215	2025-11-24 15:47:50.982215
f84e8f35-c8da-498b-977c-559c4ac11798	3462ddf3-f516-4363-87f8-44d2ba92da64	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:47:55.733818	2025-11-24 15:47:55.733818
1240cbc0-668f-43ee-9be0-00983a81cac4	87dd917d-e936-49b5-8457-1a0b2ee49565	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:00.417473	2025-11-24 15:48:00.417473
090518c6-099a-403d-8318-46bba0fe33a5	7244fa14-e0a5-4366-a31a-e136039445ba	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:01.777227	2025-11-24 15:48:01.777227
e77ac460-bd0d-4544-bf72-b9769935f4fc	47e1c021-cef6-4889-baa9-d824d461da1d	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:10.247414	2025-11-24 15:48:10.247414
45868a49-195a-4195-a31b-6c8d303c58c2	d142142b-d819-4303-bdff-8d2c3a10e327	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:14.634519	2025-11-24 15:48:14.634519
fc988a9b-bd52-4c4b-8f89-f7a9f702b304	dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:17.638252	2025-11-24 15:48:17.638252
a6d2d4f0-5ddb-4e1d-a1b3-5cb103d21c6e	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:20.604551	2025-11-24 15:48:20.604551
6b2b2ed9-af64-4875-88e3-fff99d40067e	262d8859-2d57-4341-bba6-228f87871a4a	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:23.489181	2025-11-24 15:48:23.489181
62436294-f4be-483d-8317-1bec082df700	2161ca82-71b5-419f-bd3d-4a38216dca25	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:25.646747	2025-11-24 15:48:25.646747
c5602ceb-8c04-411e-8b03-a7255f16b0d3	600a025b-0c42-4f27-9475-0316676f584c	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:46:12.991302	2025-11-25 01:03:07.438
4995fbc4-fab0-449e-8cd9-d60d0c6533be	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:46:20.369865	2025-11-25 01:03:07.441
121e9cfc-4635-4f22-93d7-225bc783356b	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:47:40.675806	2025-11-25 01:03:07.444
464aeb01-dfbb-4110-986e-56538965cf3a	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:47:02.105788	2025-11-25 01:03:07.42
ab45f734-524b-4451-9444-48f62f2c2dec	7e3203dd-6fe2-47ad-bd33-a4746782eca2	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:34.895888	2025-11-24 15:48:34.895888
9fe0a11e-c3fd-4999-b3bc-5e9cafebd3e6	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	15.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:45.858893	2025-11-24 15:48:45.858893
59a5cf64-f26d-44ae-aa96-5ab5868460b3	726d7760-d6d8-4b9c-bc15-c751fd612610	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:54.3705	2025-11-24 15:48:54.3705
548867b6-efa9-451a-9603-198e4b67cd4a	3bd5a661-dabb-42a3-b7bd-62baae50f6ed	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:14.310186	2025-11-24 15:49:14.310186
dcdf4641-cdb2-42f4-b446-f5da4ff5eaf1	dc47d96f-a72d-417b-a156-fc743e5e2f1a	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:19.836068	2025-11-24 15:49:19.836068
86190a73-7989-4794-a159-afe013b3d5e9	cdf9dfc9-a2db-4b12-8562-1009f500af78	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:25.991087	2025-11-24 15:49:25.991087
e04c38e4-bc3d-4f57-aaa2-f6538010c9f7	5b686276-91a2-43a8-a6fd-30e72c98f252	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:31.930879	2025-11-24 15:49:31.930879
f1574c0e-4802-447b-93b8-c6ee29ceacd1	0c7de719-6c75-4e5f-bead-03f772c73221	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:36.435039	2025-11-24 15:49:36.435039
37136ac1-b526-4f4b-8b73-f146fff0b939	87dd917d-e936-49b5-8457-1a0b2ee49565	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:38.164719	2025-11-24 15:49:38.164719
1cb4e9d8-f402-43aa-a1dc-6bd555fc2a25	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:40.922878	2025-11-24 15:49:40.922878
c9da37c6-4d9a-4bf6-9559-2a42b5500f8f	47e1c021-cef6-4889-baa9-d824d461da1d	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:41.505523	2025-11-24 15:49:41.505523
f5eb656c-4a59-47eb-8825-9fc6bcc0a951	d142142b-d819-4303-bdff-8d2c3a10e327	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:43.298366	2025-11-24 15:49:43.298366
d083f26d-bfac-42ce-9011-9ff4c4f3dddc	5546bd4e-c045-4d52-8cd6-79408f8af1a3	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:49:50.80831	2025-11-24 15:49:50.80831
8a839d16-9b55-4394-affd-df6fae05db57	a5719761-6a08-41c6-99be-e1b631c41975	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:02.002336	2025-11-24 15:50:02.002336
40e03a4a-8cba-49cc-b5cf-c9dd5784eb9d	edc3bf2f-4847-4758-81cf-6a0c84cda676	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:08.423503	2025-11-24 15:50:08.423503
b0d8f3b2-9f34-4e63-9952-ce13339765bb	e823904a-7a2c-474e-895b-ba225efc6751	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:17.088254	2025-11-24 15:50:17.088254
34840e21-0b87-4477-a67e-cdf746cf173b	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:28.951259	2025-11-24 15:50:28.951259
08adbbb6-308e-4273-9e78-7c1700b57006	f4bf6416-f972-4d4e-99e8-04a89fd369e2	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:29.224267	2025-11-24 15:50:29.224267
57abf626-e88c-4eca-8349-bdf8dc088e33	1b32643f-336d-42af-bb06-99423ec5e622	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:31.990164	2025-11-24 15:50:31.990164
792be5f6-2f33-450f-a3c5-b59ff8046338	53dc5a74-fab1-4942-a54f-21a5f34b45ae	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:34.248586	2025-11-24 15:50:34.248586
e490417b-a863-4089-80fc-7b12fb7bd879	98b52742-77b5-4a61-a42c-ab4dba2c9474	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:34.60475	2025-11-24 15:50:34.60475
943b0de9-033c-4ebc-862b-db415d55168e	0dc41e0d-ef7f-43e7-b467-1678112877f9	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:50:38.86721	2025-11-24 15:50:38.86721
50abe5fc-035a-4e03-94d8-664b43e79b3f	c2ca5e25-f355-48c5-963f-58f9abd5e319	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:51:04.991003	2025-11-24 15:51:04.991003
34309087-7c74-4009-bd38-16e49c7e25ad	eb30a3b6-ba28-4726-b0a5-43b238720619	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:50:43.219268	2025-11-24 08:51:07.758
97fdf3b2-473f-49e8-b765-36055da246ed	7e52a1dc-9d2b-4d67-9546-21017a044c8d	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:51:13.810503	2025-11-24 15:51:13.810503
ba9da6fd-c39e-4a19-97c8-521caa556be0	3462ddf3-f516-4363-87f8-44d2ba92da64	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:51:19.016844	2025-11-24 15:51:19.016844
0a9d1a2a-bbc2-40fe-a857-d38573340dbc	7244fa14-e0a5-4366-a31a-e136039445ba	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:51:25.4624	2025-11-24 15:51:25.4624
000c5e30-6964-4c23-a606-ea4258ddb915	dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:51:29.481894	2025-11-24 15:51:29.481894
e5b7b145-533a-4fac-890a-1a240baac94d	262d8859-2d57-4341-bba6-228f87871a4a	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:51:32.512703	2025-11-24 15:51:32.512703
cd8c650d-18c8-404b-b1eb-45717e38cb88	c2ca5e25-f355-48c5-963f-58f9abd5e319	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:51:53.256168	2025-11-24 15:51:53.256168
448ca2af-f13a-4630-9b80-42ebfe731f6c	432950d8-25a9-4726-b24f-6869f9c12c10	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:52:40.246458	2025-11-24 15:52:40.246458
881a2974-0522-48d9-993c-7f8766d729db	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:52:49.662932	2025-11-24 15:52:49.662932
82330590-8268-4b05-b82a-c0a50fe450e4	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:53:02.857775	2025-11-24 15:53:02.857775
07937361-6ddf-4942-97c4-971ce39344c6	0d874a0f-1b7a-4004-8cda-1952c40f5928	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:53:08.465545	2025-11-24 15:53:08.465545
b5a50104-a161-42e8-9ec5-1a504e5b50de	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:53:13.946302	2025-11-24 15:53:13.946302
9003b468-1f13-4ebc-b1d3-2dcd08f221d1	d2e851bc-4408-4b55-9aeb-7a551d790f09	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	50.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 01-1763974449050-415617604.png	TiÃªu chÃ­ 01.png	draft	2025-11-24 15:54:09.088181	2025-11-24 15:54:09.088181
f07a9fe4-0cb4-4e9f-9797-7586460de991	04d20169-ff00-42ad-b2a2-81f9adf94c2f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:54:13.575811	2025-11-24 15:54:13.575811
44d81eac-f8fe-41c3-abb5-660238d9e83c	10392de9-00c3-4461-8c03-8b9df80b9dd1	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:54:21.489335	2025-11-24 15:54:21.489335
75a6ee3f-0cd0-48bb-97e5-4e13c5915dac	91f0d26e-c70a-4522-ba08-2a38cf823fd0	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:54:36.080157	2025-11-24 15:54:36.080157
abf1f89b-a281-4037-a19b-f314e9f725cd	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:54:48.317968	2025-11-24 15:54:48.317968
8ba429d4-48b0-4264-8915-99f19d57c73d	a4f478bf-d50d-4fe6-a339-de512cbbab8b	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:54:56.050409	2025-11-24 15:54:56.050409
97ff4a1e-a668-435e-8a35-a72fa9c5b3da	9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:55:07.962793	2025-11-24 15:55:07.962793
0d05e249-ed49-42ea-9f3f-86a9bfbe3755	2c25c3bd-19b0-4aab-a99e-806e527815fe	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:55:21.266537	2025-11-24 15:55:21.266537
e97b1eb9-1a3b-4c09-b778-90394f310b88	c490447c-6617-40d5-99a1-11e57139290a	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:55:31.319599	2025-11-24 15:55:31.319599
62d361b7-95a7-467b-82f2-3ff8c3bb42f3	432950d8-25a9-4726-b24f-6869f9c12c10	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:55:37.682944	2025-11-24 15:55:37.682944
30461438-de0e-471e-830e-b322e1071266	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:55:42.689544	2025-11-24 15:55:42.689544
819f3622-47af-4e58-9f1c-4fdea2638b5a	593c88af-c03f-43fa-b39c-69cfc510fc20	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:56:00.356086	2025-11-24 15:56:00.356086
684905c1-966f-45ea-adbe-4775a4440421	420e7cc2-f2ba-4fe6-8351-730fb1e2b936	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:56:06.931509	2025-11-24 15:56:06.931509
77b084d3-8eb9-4af6-920e-6dc9a87075be	b8ee94cd-6988-47b8-8e43-67193def36b6	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 02-1763974567608-252463220.png	TiÃªu chÃ­ 02.png	draft	2025-11-24 15:56:07.634181	2025-11-24 15:56:07.634181
9deedc5b-64a3-4ac3-9ebc-9efebcf18d49	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:56:20.908381	2025-11-24 15:56:20.908381
7b982b23-89a9-46a0-9928-214b2d78abf9	e2a12005-4697-4566-91d8-fe76936856e3	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:56:33.912297	2025-11-24 15:56:33.912297
c9c42da2-3ef5-407b-bb8e-fac4524de35a	88e5c0e3-6caf-4066-8851-e201c76e2ec1	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:56:14.343043	2025-11-24 08:56:42.551
deb6901f-70b6-4b6b-a217-d6196cc6fe64	97186d30-1727-43b3-bd5e-685ae3cc8f78	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:56:50.028376	2025-11-24 15:56:50.028376
41c8b499-8b51-425a-bf1e-17fc30dbd486	5da1d907-cb33-4043-b7d5-3a71d96afae6	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:56:53.459782	2025-11-24 15:56:53.459782
50ffa6c0-3018-440c-8bb9-aa58a6513f53	24703ccc-61d6-4e27-9325-8dd505493afb	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:01.566895	2025-11-24 15:57:01.566895
e22d9426-9fde-432a-bb19-466346b0d2b8	017d894c-c894-454b-8957-25be9be88d40	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:57:07.115017	2025-11-24 15:57:07.115017
f46fb5d6-6176-40aa-97da-704fe4516993	473fb095-1711-489f-8b16-6ff5aac4f1d5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:12.954106	2025-11-24 15:57:12.954106
48dacc0b-b93f-4e44-bdd0-f031a42c92d1	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:20.566982	2025-11-24 15:57:20.566982
f80d7fdb-1a1f-41ac-8136-cf9829b04258	4baf6310-700f-4a03-84e6-24d2efa70d69	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:28.041827	2025-11-24 15:57:28.041827
c42e26b4-7fd8-444c-87c4-ad850be96486	b5e500c7-e88c-4922-84ba-8baec799d1b3	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:36.9351	2025-11-24 15:57:36.9351
732979fa-28a8-45bd-bcac-db744e17dacd	c981c60d-9dec-44ef-bbba-5973de4977b2	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:45.879621	2025-11-24 15:57:45.879621
7c75e8d0-b730-490d-874b-7d08dd3b7bf5	d38a02ec-2612-466e-9e40-dcbf8ec952bb	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:47.114962	2025-11-24 15:57:47.114962
8b2fdf74-119b-4cd7-a18f-2168deee2beb	936d4b77-3c36-4008-97fe-7742a432e046	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:52.490123	2025-11-24 15:57:52.490123
d038be23-dae5-463e-8c9e-ce62bc2e675a	267e5cb1-334e-4830-beb1-d94707b486bb	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:57:54.448164	2025-11-24 15:57:54.448164
8ed2524f-4a9a-47b9-9e2f-1ba27ff96aa2	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:56:25.398629	2025-11-25 01:03:07.442
3d99a141-7644-4f32-a93d-a027065ce36e	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:56:37.534679	2025-11-25 01:03:07.444
9a8e1a23-e72e-46c1-ad59-e3baec264c3c	4b68575e-b415-45b1-9338-b43937cb7a76	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:57:14.764161	2025-11-25 01:03:07.448
d9eebaf9-4161-4b3b-835a-a095a78e9545	600a025b-0c42-4f27-9475-0316676f584c	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:56:02.389104	2025-11-25 01:03:07.438
af26ebb0-523c-4a3c-860c-b7849dca91a2	a48698a9-0d29-4e15-831a-97f0b17385ac	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:04.935984	2025-11-24 15:58:04.935984
1a0b3857-4c7e-4e0a-8c2d-4a4862fd4215	c07e54b8-588b-41c1-bee9-c4aed0726511	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:08.735034	2025-11-24 15:58:08.735034
9b115c42-4096-498b-a676-6fc002e91a03	4caf250d-329f-4d8e-ae37-c88a914a153d	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:16.170507	2025-11-24 15:58:16.170507
cb7142cc-655c-4d9f-84f9-239b2931d0a3	b3f3e20d-6661-46e8-b58b-c974643c412c	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:23.539543	2025-11-24 15:58:23.539543
504038dd-d306-45c3-9b4d-34c27f947ff1	7112a886-e9b0-4e40-80ef-a73f9cba962e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:28.087525	2025-11-24 15:58:28.087525
d24470b6-dd32-47c1-8691-aef9f48d62d0	f4bf6416-f972-4d4e-99e8-04a89fd369e2	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 03-1763974708883-369440963.png	TiÃªu chÃ­ 03.png	draft	2025-11-24 15:58:28.925622	2025-11-24 15:58:28.925622
60c6b477-c888-4913-ba67-11700818702d	04fddf93-0005-43c2-bd35-ca2b965fe44b	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:31.311511	2025-11-24 15:58:31.311511
0af28831-211c-4a53-8083-f003fb6aa8d3	be878744-4347-47da-9a82-7a1dde8a1077	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:38.412331	2025-11-24 15:58:38.412331
7c15a7d8-deae-4502-9264-8800df204188	c8ca26c8-231d-4806-942a-afbb8a0d80c0	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:39.975123	2025-11-24 15:58:39.975123
b18c5645-c18a-46fc-bcec-621f2fce3171	1b32643f-336d-42af-bb06-99423ec5e622	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	/uploads/scores/TiÃªu chÃ­ 04-1763974721041-716090395.png	TiÃªu chÃ­ 04.png	draft	2025-11-24 15:58:41.090851	2025-11-24 15:58:41.090851
45f6d1f5-51dc-407b-be15-6e81223f29ad	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:49.129653	2025-11-24 15:58:49.129653
561869d9-0fde-466f-9ee9-b577975f1934	98b52742-77b5-4a61-a42c-ab4dba2c9474	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 05-1763974735971-762787243.png	TiÃªu chÃ­ 05.png	draft	2025-11-24 15:58:56.053368	2025-11-24 15:58:56.053368
36006262-28f9-47ca-9192-5616083dff1c	a8585392-847e-4c9c-865d-0b79bbed54f0	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:56.091948	2025-11-24 15:58:56.091948
76bdc4c7-19a9-40ad-a348-c8166b3d0cbe	d9337788-d07b-487e-a8ea-79bd9a237706	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:58:57.048515	2025-11-24 15:58:57.048515
4342da80-411b-4c96-8a85-0c1048ef6c59	64744f6b-59e1-4590-a3ff-78b66b9a90a7	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:01.519141	2025-11-24 15:59:01.519141
e7979dc4-fd82-4cad-89f5-57323e6652b6	8a5ebc3d-20ee-4780-b286-64c434c87a72	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:02.68151	2025-11-24 15:59:02.68151
8119b891-5523-4257-adc9-5bff6261d49a	0665d813-c605-4a69-956f-245763cd28e9	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 06-1763974744844-710369320.png	TiÃªu chÃ­ 06.png	draft	2025-11-24 15:59:04.927735	2025-11-24 15:59:04.927735
bec4eb59-3f19-48b0-8ac1-a0cc47db6338	b487f5d9-5e12-478d-8798-f6203a871885	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:08.887694	2025-11-24 15:59:08.887694
831daa1f-bcab-4836-9184-e8d072b1967c	ab174e0f-5d07-4ee0-80de-58e952cfacfa	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 06-1763974751184-465658665.png	TiÃªu chÃ­ 06.png	draft	2025-11-24 15:59:11.275767	2025-11-24 15:59:11.275767
531acc58-6c7d-487a-832e-09e11a6da6d7	eb7bd701-5795-43cc-8391-21426990fbb5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:16.91151	2025-11-24 15:59:16.91151
12b6f1d4-6dca-48e9-9013-3dc74a7c25c8	1418079e-67b7-465c-9ac3-b626ea3dfdbf	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:22.160247	2025-11-24 15:59:22.160247
62f1df9c-952e-45c1-8f0b-79f8071e0574	90dc2f36-7803-4077-9ffa-c33881dba242	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:29.495331	2025-11-24 15:59:29.495331
41a1bf02-17b3-40aa-8381-68e0630ab5fb	c6a60793-756f-4526-8f3f-ed2f9b7703a4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:36.895465	2025-11-24 15:59:36.895465
4e73da85-2cd3-4d1b-926a-e369af0c6a15	07132dd0-4bd5-4601-8a9b-6d05b87d354c	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:42.370748	2025-11-24 15:59:42.370748
de1ef97a-dd79-4be1-b980-6c08c6428f1d	3e76bba7-f386-4124-ba55-3eea01d1a38f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:49.1109	2025-11-24 15:59:49.1109
103d5dcd-d8af-49cd-af90-1c820e12e7f1	381a96ff-c413-4412-8b19-3c0117aea3ec	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	20.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 07-1763974793762-358665895.png	TiÃªu chÃ­ 07.png	draft	2025-11-24 15:59:53.847061	2025-11-24 15:59:53.847061
3ec1766f-1ab8-4adb-ae59-354400ca129c	bcada071-a37b-4192-8c42-afdc522c3bf3	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:59:56.887618	2025-11-24 15:59:56.887618
957e425e-1855-4d01-bb72-9508203c8e9e	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:02.346085	2025-11-24 16:00:02.346085
0232031c-1dc9-41ce-9807-4ee8892ecd37	036c63d8-d0b1-412c-ac70-40bf5d359877	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:07.329272	2025-11-24 16:00:07.329272
363b4bf6-f0e8-44b7-8ebf-27c0befc3c34	29ca3068-2c31-4899-bd25-aa45f93abe93	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:17.503121	2025-11-24 16:00:17.503121
2d13af5f-0eaa-43ae-aa27-e23b465dd1d9	2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:00:21.32298	2025-11-24 16:00:21.32298
d58521a2-9614-45d9-a7bc-4bb7bd312831	165aae17-5f5b-476e-bd69-05c16e9e4c24	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:58:18.675698	2025-11-25 01:03:07.457
0b613a5c-c26d-4d9e-929d-09421de13b07	c79e3144-f71f-49ed-92fb-421e459bf2af	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:27.472987	2025-11-24 16:00:27.472987
8166892c-da86-4449-8e09-185c122d3adc	1463af4f-223f-4146-ae23-9a326a61ad7e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:33.450099	2025-11-24 16:00:33.450099
2bcf7914-c939-48b9-9d61-194c2d8c296d	04ebee63-5624-4a9f-9a69-7b519ddc2bef	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:38.130037	2025-11-24 16:00:38.130037
006d330f-0982-4f17-b36e-177c479d7e79	cc239035-3c1b-41b2-a71a-2a43f5728543	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 08-1763974838811-964199525.png	TiÃªu chÃ­ 08.png	draft	2025-11-24 16:00:38.899763	2025-11-24 16:00:38.899763
fd01bb40-83fb-4e0a-8181-8960c671f7eb	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:44.466262	2025-11-24 16:00:44.466262
43311515-0f35-4c9c-9e22-27e7ac1621e9	0797b27a-f581-418c-a1fd-4c85a8442591	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:49.042664	2025-11-24 16:00:49.042664
9a74d50e-8b29-4a8c-9845-548294e7063e	12a78dac-7c82-4032-b61d-53b858b29b9d	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:00:59.135895	2025-11-24 16:00:59.135895
7eb42763-713c-4232-8394-4ac0e391f0ff	b5927146-8aaf-4409-8142-3f4c11c4f2b4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:02.618215	2025-11-24 16:01:02.618215
71f8e025-7c74-480b-b996-8de4bb4a719d	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:06.091241	2025-11-24 16:01:06.091241
b3fc1f42-baf4-4fbc-9bd5-1c482d255301	a6d07339-22c4-4da0-ab27-c3097e68cf5f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:11.578145	2025-11-24 16:01:11.578145
2c975e87-3cdf-4314-bb85-3b4db4189c01	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:14.426276	2025-11-24 16:01:14.426276
e2b45608-da5e-4008-899a-621b1252ac7e	140368b6-7511-4d5c-a434-4fb50da9f877	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:19.160383	2025-11-24 16:01:19.160383
75e68e1e-1ee8-4f7c-bdf2-61d73083602b	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:25.664224	2025-11-24 16:01:25.664224
4eebc80b-d504-4fbc-8752-31496aaa598b	7313230c-811c-45e7-ba72-bc8ebcd65f7a	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 09-1763974885692-383530832.png	TiÃªu chÃ­ 09.png	draft	2025-11-24 16:01:25.821406	2025-11-24 16:01:25.821406
cfe03032-a275-4c1f-8a1e-863f0ea0cc12	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:31.499204	2025-11-24 16:01:31.499204
66965bbd-0400-434e-982d-e50e321374ab	d32ec9db-b64f-42c7-a21e-16a443599cf5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 09-1763974892877-843457492.png	TiÃªu chÃ­ 09.png	draft	2025-11-24 16:01:32.953708	2025-11-24 16:01:32.953708
0930f422-213e-433d-9ae9-485679f1387a	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:01:37.186782	2025-11-24 16:01:37.186782
b76dbf2a-6966-44a3-8cbc-14e6fda140b3	06d115ef-b738-4f1d-9a9c-9e8a0150def5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:02:01.086351	2025-11-24 16:02:01.086351
d6b576e1-63ae-425a-b14a-cba02fb16c1b	95ecadd0-d137-4bfc-b69b-12cf556a467c	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:02:10.135299	2025-11-24 16:02:10.135299
ecba0cd9-1b38-477c-a306-4d99fd67cd1e	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:02:17.421959	2025-11-24 16:02:17.421959
ecf38c0f-de7c-4089-9ed9-2a84c266e7bf	a88fb457-de23-41d1-a217-1516fc5557de	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:02:24.815067	2025-11-24 16:02:24.815067
4e6fa173-9468-4659-b086-9e9ae09df56f	d016962d-b0c4-4e42-942f-9cad60ba440f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:02:31.042271	2025-11-24 16:02:31.042271
30b2c827-b35c-4f67-900c-ae8171cdfd54	bcfac4d1-207b-4978-b551-1719db9d7ae8	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:02:43.524298	2025-11-24 16:02:43.524298
2b26ba34-e6a1-4728-86e5-cea4f9d98de0	20d84ee4-ac0a-4365-ad68-83359862ae69	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:02.327922	2025-11-24 16:03:02.327922
6ae04b44-0051-4b0f-abc8-7f7daba4a448	d9d26ff4-1341-4c25-82e1-8ec562b829f9	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:10.593105	2025-11-24 16:03:10.593105
6bc604ce-1f36-414b-ace4-828706a5f6e3	d1635049-c122-4492-9597-7e125fcf09f8	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:13.313453	2025-11-24 16:03:13.313453
83cc46d9-f8f8-4e62-b0ec-5ff1f2a15496	533ad720-b054-43ff-a802-368ec07ad8e5	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:18.71211	2025-11-24 16:03:18.71211
bbfa4f58-22e9-4d46-ad61-703c8898c346	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:20.942695	2025-11-24 16:03:20.942695
12d764c3-ffa2-44dc-9bdf-b898496108e7	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:52.999769	2025-11-24 16:03:52.999769
99d1aaba-8840-4fae-8d6b-6033fe2f8cef	ef232bc9-a97d-46cf-b838-ea67e96b5271	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:39.791631	2025-11-24 16:03:39.791631
749cd469-928d-49c2-8ddb-8b7e46fddf11	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:23.698357	2025-11-24 09:03:41.928
0525a7e9-0d5b-4748-9eec-5ed4fcc4095e	f8a1368d-2826-45ab-84a2-6e25a76a3a74	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:03:29.427531	2025-11-24 09:03:45.514
826c523f-1769-4224-bb6c-f276138ac996	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:01.428298	2025-11-24 16:04:01.428298
ac0c9cd0-cb90-46b0-a974-e0dc04a0df3a	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:03.725914	2025-11-24 16:04:03.725914
55c1eec2-af04-4a61-8a1a-2890173e4e34	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:04.4088	2025-11-24 16:04:04.4088
3eeb6d62-846c-4b16-9a5f-38dcc23d6ed4	68a08d0e-6535-4e43-adeb-fa90fa585e59	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:11.403619	2025-11-24 16:04:11.403619
8cc0e78a-ceef-43b4-b8f4-ca2bc647f9ee	246965b3-e65a-48f9-9f68-fdda80be8169	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:12.134015	2025-11-24 16:04:12.134015
99d70a31-fa2b-4c86-933c-54c40806b4e0	db10be95-c13b-4487-b8d2-d03a5e784e69	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:28.212829	2025-11-24 16:04:28.212829
8187c358-217c-4f4f-8a83-598af7d1795f	db9717f5-c7a7-4532-97b1-e33f0ec86750	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:31.122598	2025-11-24 16:04:31.122598
d2339293-7178-4e8d-9b23-e21acd2ed04b	ef8f8ad5-2255-4292-a371-a681701526bc	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 10-1763975072632-146396347.png	TiÃªu chÃ­ 10.png	draft	2025-11-24 16:04:32.721204	2025-11-24 16:04:32.721204
0744273f-9c99-41ae-8f56-a34fa28623e5	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:39.412817	2025-11-24 16:04:39.412817
f127421f-38bd-454e-8d80-4122dc45b124	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 11-1763975083080-535400687.png	TiÃªu chÃ­ 11.png	draft	2025-11-24 16:04:43.153643	2025-11-24 16:04:43.153643
4eb102d4-4746-497e-b34d-f44c5403cdf5	750d4861-d84c-4622-a0f5-e709289e603b	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:04:45.578066	2025-11-24 16:04:45.578066
7ffd4478-88be-4d34-b3ff-842885310e12	8c181441-36a7-432a-a2de-2026909f9a41	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/TiÃªu chÃ­ 11b-1763975091219-366965168.png	TiÃªu chÃ­ 11b.png	draft	2025-11-24 16:04:51.385506	2025-11-24 16:04:51.385506
6bd810f5-69d9-4d6a-866f-d4db8cd1cf55	2727281f-30a6-451a-8aa7-adf9d33434af	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/12-1763975100756-827501539.png	12.png	draft	2025-11-24 16:05:00.848398	2025-11-24 16:05:00.848398
bf81948c-6648-42c3-a752-86ff979a401a	97ee726a-f9c6-4c65-9794-543a6feb7a1b	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:05:04.559794	2025-11-24 16:05:04.559794
a2c9b58f-9930-4ebc-ac5c-6ec8c2d20a4c	02507c7a-6a42-4bdc-a8b8-79cc07d58eac	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/13-1763975108453-317397818.png	13.png	draft	2025-11-24 16:05:08.5448	2025-11-24 16:05:08.5448
340fefd2-3a9c-44d8-8f3e-6480be8400a0	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/14-1763975119411-679174922.png	14.png	draft	2025-11-24 16:05:19.442432	2025-11-24 16:05:19.442432
5dcf0ab8-018c-433c-a022-534eb9ca744f	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:05:20.016138	2025-11-24 16:05:20.016138
65d96eed-8182-47d4-bac5-cfd0316c6c86	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:05:24.571361	2025-11-24 16:05:24.571361
025332d0-b569-47d4-a52b-cd7f879a3b12	1f752b6d-e8ff-4061-97f6-310f6fa0664b	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:05:25.349626	2025-11-24 16:05:25.349626
74924afd-851f-40ae-a41c-01696ab8a621	d574da97-c404-48bc-8ddb-1d0dd6943d04	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/15-1763975127576-821647785.png	15.png	draft	2025-11-24 16:05:27.667974	2025-11-24 16:05:27.667974
fc4f9946-1737-45bb-9230-3f2dc875c22a	973abd8b-5798-4c77-912f-2f036e0e2d28	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:05:34.71708	2025-11-24 16:05:34.71708
ea5b1ba1-c3ef-4947-82fd-69f9e4c3a618	a03680b8-7258-4d8f-95dc-29aaba658479	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:05:43.533506	2025-11-24 16:05:43.533506
b77773c8-eaa6-4a38-a9ec-60ec027ec4a3	4ee3df5c-a054-4b93-9f97-52a99196cdfe	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:05:52.897098	2025-11-24 16:05:52.897098
320dca51-4ab7-441e-a5cd-fcf86b4bac92	23db48b5-e04d-4351-b095-bdf2defff0c4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:06:04.432224	2025-11-24 16:06:04.432224
6b7a32f1-28b3-4ff3-a0c7-c7c960de7270	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:06:15.321164	2025-11-24 16:06:15.321164
6dbd73c0-2c3c-48d3-9034-e22f305c928f	f05a6cc8-a921-4f10-99f5-0b5afda37328	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:06:20.974122	2025-11-24 16:06:20.974122
e1a7c58b-7f25-44b3-98c8-4ccb9a9f6167	18aaf397-5d9c-42f9-a327-fa0fba8d477d	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:06:36.091863	2025-11-24 16:06:36.091863
bcbcf14d-1ea9-4a2f-bccf-1b4a7817f17d	c869685a-fd7e-46ed-8af6-9d8c6b74f9de	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:06:42.837159	2025-11-24 16:06:42.837159
e341a34b-1b8f-4b89-b089-82deff0c27f3	884e9fae-75d3-483c-b444-a464ac0130b9	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:06:56.182461	2025-11-24 16:06:56.182461
d5822d13-1e11-424a-b985-0ba2d12300bc	ffe4c55a-155d-409f-ad66-49ed6be0ded7	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:06:58.978957	2025-11-24 16:06:58.978957
e298f10a-13ba-48e3-9f1d-ef69a7d7fc18	485d3228-8245-454e-bc68-f2ce6c944263	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:12.610939	2025-11-24 16:07:12.610939
15a36717-48e6-4748-a6bc-e8a5717ff841	94b798d5-13b9-49ad-9d22-228a3f07bfb5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:23.818825	2025-11-24 16:07:23.818825
173e881f-a989-4aad-8baf-f550a1784947	d555ced7-1211-4d31-8c05-cc44b14c20a1	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:37.525074	2025-11-24 16:07:37.525074
a832f756-129c-4fc3-b352-3b180071658c	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:39.938793	2025-11-24 16:07:39.938793
3eb6a041-68a3-42df-9e2d-6d2f964371cc	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:42.064685	2025-11-24 16:07:42.064685
a74c58c7-221e-4129-935d-52bbc90a1465	73f03686-ee9a-4579-b3bc-3303e354e180	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:44.217833	2025-11-24 16:07:44.217833
61801c4d-ccb7-4dd4-8368-92176d6bbe47	5380bbd9-3b86-40ce-8597-2c87077ff5f8	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:46.680558	2025-11-24 16:07:46.680558
c5a74aca-6778-411a-94d2-2c1e7abf0feb	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:49.53653	2025-11-24 16:07:49.53653
e3cfc1cf-d315-4595-bd6b-d7486e15ba1e	0665d813-c605-4a69-956f-245763cd28e9	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:52.454728	2025-11-24 16:07:52.454728
0f9f4d6a-ae78-4f78-9587-c21cf8b14305	ab174e0f-5d07-4ee0-80de-58e952cfacfa	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:55.828395	2025-11-24 16:07:55.828395
37ec50bd-83fe-4508-82ca-278888e8eb35	726d7760-d6d8-4b9c-bc15-c751fd612610	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:07:52.807466	2025-11-24 09:07:59.195
141b7930-1abd-4c81-b3fa-3545811a17d0	87dd917d-e936-49b5-8457-1a0b2ee49565	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:02.177294	2025-11-24 16:08:02.177294
b3b73c56-300a-4d03-a84e-32f81d93c360	47e1c021-cef6-4889-baa9-d824d461da1d	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:05.744199	2025-11-24 16:08:05.744199
975e2712-3416-4a2c-a34c-daff364252ce	d142142b-d819-4303-bdff-8d2c3a10e327	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:10.544361	2025-11-24 16:08:10.544361
62f36ce5-d7c8-4d0e-99aa-f3ddc67c8dc6	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:14.552515	2025-11-24 16:08:14.552515
5b5b0f36-4d3b-4706-83d8-89802ce11a42	2161ca82-71b5-419f-bd3d-4a38216dca25	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:17.120239	2025-11-24 16:08:17.120239
ad43fcc7-4407-4690-9b2c-df374bba1a31	381a96ff-c413-4412-8b19-3c0117aea3ec	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	20.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:43.493705	2025-11-24 16:08:43.493705
94318235-c027-4703-8269-5c1d45015e0d	7e3203dd-6fe2-47ad-bd33-a4746782eca2	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:52.028506	2025-11-24 16:08:52.028506
3ca2ba63-4cd5-44ca-aae6-765f88079ac8	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	15.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:08:56.833362	2025-11-24 16:08:56.833362
f93d4e41-2033-4e53-832d-303268864847	3bd5a661-dabb-42a3-b7bd-62baae50f6ed	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:00.664195	2025-11-24 16:09:00.664195
a3a3f44d-232a-457b-9670-8cf976cd3a89	dc47d96f-a72d-417b-a156-fc743e5e2f1a	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:02.993374	2025-11-24 16:09:02.993374
af545c1a-db40-4a7e-865d-8cfffca0ebec	cdf9dfc9-a2db-4b12-8562-1009f500af78	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:06.705303	2025-11-24 16:09:06.705303
1d4ec388-2ac2-474a-99e3-e2a43948f0c6	5b686276-91a2-43a8-a6fd-30e72c98f252	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:10.128343	2025-11-24 16:09:10.128343
f03f7223-badd-4ece-ad27-28675dcf15e1	0c7de719-6c75-4e5f-bead-03f772c73221	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:12.829587	2025-11-24 16:09:12.829587
5331da24-7d37-41b8-a45d-f58554a2d134	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:16.073236	2025-11-24 16:09:16.073236
0cb2d784-b16b-47f8-8140-47852eb24ae2	5546bd4e-c045-4d52-8cd6-79408f8af1a3	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:19.145032	2025-11-24 16:09:19.145032
619d6bda-0b0e-49fb-b17f-7bf3164d3446	a5719761-6a08-41c6-99be-e1b631c41975	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:21.375986	2025-11-24 16:09:21.375986
a1758ac9-c921-46ba-bdb3-cf9f1a010acb	edc3bf2f-4847-4758-81cf-6a0c84cda676	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:25.053456	2025-11-24 16:09:25.053456
b9a56616-8ec9-4026-915d-9e21c54bc81f	fa96f655-905e-4a20-b489-8c8d3295ec83	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/16-1763975365659-469158176.png	16.png	draft	2025-11-24 16:09:25.756098	2025-11-24 16:09:25.756098
d978ad24-0f34-4a90-8376-f1d51823b02e	cc239035-3c1b-41b2-a71a-2a43f5728543	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:26.835404	2025-11-24 16:09:26.835404
511bec33-a2b9-4946-b909-64fb99473753	7313230c-811c-45e7-ba72-bc8ebcd65f7a	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:34.274674	2025-11-24 16:09:34.274674
a332daaf-3f04-40b5-9a64-9c350fef0b84	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/17-1763975374673-290396676.png	17.png	draft	2025-11-24 16:09:34.858476	2025-11-24 16:09:34.858476
73243395-e8dc-4deb-9c19-289f11540f11	d32ec9db-b64f-42c7-a21e-16a443599cf5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:41.851425	2025-11-24 16:09:41.851425
86689e20-0080-49d9-b9d0-8677c1d20653	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/18-1763975384138-450283558.png	18.png	draft	2025-11-24 16:09:44.237823	2025-11-24 16:09:44.237823
58fb3178-0393-419a-877d-1c44961218eb	ef8f8ad5-2255-4292-a371-a681701526bc	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:50.556561	2025-11-24 16:09:50.556561
57e27fa2-eb7a-47a5-8e3f-de68f5fbbcb8	87605a36-1a09-42c9-8362-ee3f79925b46	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/19-1763975396847-774745106.png	19.png	draft	2025-11-24 16:09:56.938315	2025-11-24 16:09:56.938315
3729fd54-7003-4917-8cff-12e7e08beed1	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:09:56.974963	2025-11-24 16:09:56.974963
c30fefd3-0210-4a94-a598-849fbc7d4a01	8c181441-36a7-432a-a2de-2026909f9a41	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:01.553573	2025-11-24 16:10:01.553573
f794e68d-4b34-47ae-a68c-20f476b23f93	2727281f-30a6-451a-8aa7-adf9d33434af	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:05.041284	2025-11-24 16:10:05.041284
9c03bdc2-5c8d-4b37-8898-e85ee58561cb	e823904a-7a2c-474e-895b-ba225efc6751	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:14.508847	2025-11-24 16:10:14.508847
d8a51f93-3dda-461c-8aa7-7539d3698936	02507c7a-6a42-4bdc-a8b8-79cc07d58eac	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:17.710526	2025-11-24 16:10:17.710526
276d3c67-44e0-4a2f-bc22-b5134ac9c258	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:22.267774	2025-11-24 16:10:22.267774
ec23784f-b957-4dc2-95fa-5e884098b2ba	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:25.323613	2025-11-24 16:10:25.323613
2f13438f-d3ef-4097-b05d-4a2c01909c3c	53dc5a74-fab1-4942-a54f-21a5f34b45ae	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:34.284845	2025-11-24 16:10:34.284845
1d80b7cb-dbe7-4cb6-9c17-0338f524c038	0dc41e0d-ef7f-43e7-b467-1678112877f9	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:42.655052	2025-11-24 16:10:42.655052
6383efea-ced4-40b7-bca8-e65356bf318e	d574da97-c404-48bc-8ddb-1d0dd6943d04	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:49.806624	2025-11-24 16:10:49.806624
48f0c269-b86f-4414-881f-d444c4ff825d	eb30a3b6-ba28-4726-b0a5-43b238720619	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:10:52.428731	2025-11-24 16:10:52.428731
0c5eb818-d2af-45e8-a8df-51f62bf7cabd	fa96f655-905e-4a20-b489-8c8d3295ec83	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:10:56.839875	2025-11-24 16:10:56.839875
99455f98-a36b-4b01-816b-f9bb05a84cf0	5620079f-e61f-4e50-8571-a5c2dd9de71e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 16:10:45.229897	2025-11-25 01:03:07.416
7365c99c-3d61-41e8-a16c-c02d2840c158	7e52a1dc-9d2b-4d67-9546-21017a044c8d	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:05.245826	2025-11-24 16:11:05.245826
115e09f9-f5f1-496e-ab15-34f44756894a	3462ddf3-f516-4363-87f8-44d2ba92da64	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:11.649012	2025-11-24 16:11:11.649012
f5cbf2d4-0e82-43bf-b62b-e1282e0797fa	7244fa14-e0a5-4366-a31a-e136039445ba	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:20.938517	2025-11-24 16:11:20.938517
d45112b0-f62b-4ef5-bb56-3bfdfcc81890	dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:30.892677	2025-11-24 16:11:30.892677
5f73a5e6-489d-4a09-998f-1589e5085132	262d8859-2d57-4341-bba6-228f87871a4a	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:36.064285	2025-11-24 16:11:36.064285
9f6b70d4-ebfd-4cb7-9b88-5aae6ada7a08	432950d8-25a9-4726-b24f-6869f9c12c10	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:49.161225	2025-11-24 16:11:49.161225
45c52de1-35ec-4417-9684-d9e009e945e1	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:49.897341	2025-11-24 16:11:49.897341
07304ac8-a1d7-4864-bb74-562413ce77cb	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:11:55.583739	2025-11-24 16:11:55.583739
196be518-5679-47d4-be5b-ca62d345f7ce	87605a36-1a09-42c9-8362-ee3f79925b46	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:01.415476	2025-11-24 16:12:01.415476
101eb9bb-13f9-4146-85d9-144999a95e9f	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:04.149297	2025-11-24 16:12:04.149297
701f4072-4de2-4876-b28d-5bb0830b18bf	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:10.723335	2025-11-24 16:12:10.723335
4663dbf4-0f4c-45ff-9d02-1d638d122137	0d874a0f-1b7a-4004-8cda-1952c40f5928	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:16.305843	2025-11-24 16:12:16.305843
9f2d25be-a905-481c-bbd2-a8bdc23a6b2e	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:22.367325	2025-11-24 09:12:28.404
74453b3d-d260-448e-810c-1caf5b70060d	c490447c-6617-40d5-99a1-11e57139290a	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:47.244453	2025-11-24 16:12:47.244453
df14ba70-d8e6-4677-a3de-a6a971be963b	2c25c3bd-19b0-4aab-a99e-806e527815fe	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:49.92583	2025-11-24 16:12:49.92583
802bc3cf-e5d6-4f2a-90a8-a896c297fcbd	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:52.256017	2025-11-24 16:12:52.256017
bf1f7b5f-ab37-424b-aa30-5d37ede01953	91f0d26e-c70a-4522-ba08-2a38cf823fd0	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:54.398769	2025-11-24 16:12:54.398769
dae0ac9c-1c3c-42bf-a74d-9e3ab63f881f	10392de9-00c3-4461-8c03-8b9df80b9dd1	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:56.454717	2025-11-24 16:12:56.454717
c1d7f9ef-9fe3-4448-9d2c-45c2142db5b0	04d20169-ff00-42ad-b2a2-81f9adf94c2f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:12:58.823638	2025-11-24 16:12:58.823638
715eb6f8-ce73-4b66-a6cf-52391f8f8f77	88e5c0e3-6caf-4066-8851-e201c76e2ec1	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:13:13.392919	2025-11-24 16:13:13.392919
8611cbde-4569-4d9f-bce9-86dfcd537609	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:13:23.656066	2025-11-24 16:13:23.656066
98f6b1d2-a7ea-4a5a-8604-f74404e8b84a	420e7cc2-f2ba-4fe6-8351-730fb1e2b936	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:13:28.126947	2025-11-24 16:13:28.126947
90b0da43-89a7-406f-ad85-cd4f15fa0e96	c2ca5e25-f355-48c5-963f-58f9abd5e319	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:11:42.699899	2025-11-24 09:39:55.924
6ec5b56f-54f4-44a3-bd39-ac4c2fb291d3	593c88af-c03f-43fa-b39c-69cfc510fc20	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:13:31.422788	2025-11-24 16:13:31.422788
bfcf1d00-0323-451e-90fe-64a0de51c8da	24703ccc-61d6-4e27-9325-8dd505493afb	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:13:53.943532	2025-11-24 16:13:53.943532
931756f1-a896-4631-a09f-1276241a1b98	e2a12005-4697-4566-91d8-fe76936856e3	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:14:00.055604	2025-11-24 16:14:00.055604
6b33cd4d-3ce5-41c3-addd-8b04d79a6f52	97186d30-1727-43b3-bd5e-685ae3cc8f78	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:14:03.015616	2025-11-24 16:14:03.015616
baf64faf-4b1a-44ac-abfe-3ea0b4a5cf19	5da1d907-cb33-4043-b7d5-3a71d96afae6	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:14:07.393235	2025-11-24 16:14:07.393235
8964332c-d9ee-4e54-b935-56e46ef80511	a4f478bf-d50d-4fe6-a339-de512cbbab8b	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/24-1763975725068-595157339.png	24.png	draft	2025-11-24 16:15:25.091031	2025-11-24 16:15:25.091031
132ce859-22e0-469c-a12b-06d2631244fe	9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/25-1763975748147-57792465.png	25.png	draft	2025-11-24 16:15:48.233264	2025-11-24 16:15:48.233264
d2dd935d-f010-4454-ba5c-c7100e326a96	017d894c-c894-454b-8957-25be9be88d40	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:16:27.594491	2025-11-24 16:16:27.594491
3a4fd289-3770-439e-a27f-4b9350d5bec4	473fb095-1711-489f-8b16-6ff5aac4f1d5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:17:33.650583	2025-11-24 16:17:33.650583
c6924619-168a-43fb-b83a-5aa24d5ff7c2	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:17:43.706802	2025-11-24 16:17:43.706802
ec8c47eb-314f-4deb-ae56-9150f6d70156	4baf6310-700f-4a03-84e6-24d2efa70d69	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:17:47.293008	2025-11-24 16:17:47.293008
a3b02dca-8d92-44be-bba4-3a4dcf27ebeb	b5e500c7-e88c-4922-84ba-8baec799d1b3	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:17:56.442086	2025-11-24 16:17:56.442086
aaec37bb-0bbb-41c7-a511-d536b996c471	d38a02ec-2612-466e-9e40-dcbf8ec952bb	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:18:20.022433	2025-11-24 16:18:20.022433
81c33c1a-aa8c-4e41-832a-fd744baaf11b	936d4b77-3c36-4008-97fe-7742a432e046	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:18:34.675485	2025-11-24 16:18:34.675485
d22c8084-2d8b-4ae6-92fb-a34cb2406df7	c981c60d-9dec-44ef-bbba-5973de4977b2	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/29-1763975918356-814905962.png	29.png	draft	2025-11-24 16:18:38.449692	2025-11-24 16:18:38.449692
1658a894-6a21-465f-b5f1-e1c806ef951d	a48698a9-0d29-4e15-831a-97f0b17385ac	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:00.30416	2025-11-24 16:19:00.30416
f317f144-7d23-4b93-8dbc-2c9389f0d8cf	267e5cb1-334e-4830-beb1-d94707b486bb	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/30-1763975946500-707422815.png	30.png	draft	2025-11-24 16:19:06.586637	2025-11-24 16:19:06.586637
164906ab-bf23-4f3e-91f8-a74a2052d6a3	c07e54b8-588b-41c1-bee9-c4aed0726511	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:06.660007	2025-11-24 16:19:06.660007
d2f01c70-e49a-4e66-b579-cbd5da23d9da	4caf250d-329f-4d8e-ae37-c88a914a153d	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:11.516222	2025-11-24 16:19:11.516222
aa81e5ae-669b-4cf2-8731-a90476781486	b3f3e20d-6661-46e8-b58b-c974643c412c	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:20.976672	2025-11-24 16:19:20.976672
d1c3640e-dc1e-46fc-8bee-472a293be09e	04fddf93-0005-43c2-bd35-ca2b965fe44b	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:27.842685	2025-11-24 16:19:27.842685
54cb4b9d-099b-4cc5-83ed-22e23eaf167b	c8ca26c8-231d-4806-942a-afbb8a0d80c0	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:31.533761	2025-11-24 16:19:31.533761
001f64d3-e398-4237-933f-0e82e3c0af41	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:36.859092	2025-11-24 16:19:36.859092
834af38d-c8c0-4112-9521-b57fd078e702	a8585392-847e-4c9c-865d-0b79bbed54f0	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:46.88223	2025-11-24 16:19:46.88223
559b4263-a4fb-41bf-a6b9-b93bc736fa05	64744f6b-59e1-4590-a3ff-78b66b9a90a7	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:19:51.155484	2025-11-24 16:19:51.155484
bdf2bcd3-4603-4e8c-856e-3ac8be6d855e	600a025b-0c42-4f27-9475-0316676f584c	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:16:32.832769	2025-11-25 01:03:07.439
d5ba3044-4b21-47f3-b56d-e80722407ba3	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:16:56.099533	2025-11-25 01:03:07.442
2293d787-9352-48e3-9a16-cf3d76027ab9	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:17:18.534639	2025-11-25 01:03:07.445
aa997fad-82a5-4792-9ff0-62fe311c9e39	4b68575e-b415-45b1-9338-b43937cb7a76	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:17:44.405467	2025-11-25 01:03:07.448
f2ac1cc4-1d4e-4bd6-81b9-6ce8d6e56a62	c684de0e-7f27-4e91-87a3-4f5ae46156bc	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:17:49.769249	2025-11-25 01:03:07.451
75757f56-1dc6-40c4-9f11-e5f6ee23eeb8	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	2.00	10.00	0	0	\N	6.25	6.25	\N	\N	\N	draft	2025-11-24 16:19:14.803367	2025-11-25 01:03:07.454
4e075c25-9d2d-4152-bbb3-34970484de3a	165aae17-5f5b-476e-bd69-05c16e9e4c24	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	2.00	7.50	0	0	\N	7.50	7.50	\N	\N	\N	draft	2025-11-24 16:19:30.346545	2025-11-25 01:03:07.458
995b27aa-c791-4138-abdb-95b3deaba1d6	60087a36-e314-4fc1-b4d7-9aa1a33e4109	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	5.00	0	0	\N	5.00	5.00	\N	\N	\N	draft	2025-11-24 16:15:57.773165	2025-11-25 01:03:07.435
f03674bd-70be-4fc0-ae00-a4ec63618748	b487f5d9-5e12-478d-8798-f6203a871885	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:00.16999	2025-11-24 16:20:00.16999
a3784a98-aef6-44a6-86e0-8601c54d773c	1418079e-67b7-465c-9ac3-b626ea3dfdbf	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:02.613805	2025-11-24 16:20:02.613805
72d0c2d9-bd51-4673-952d-1ec8caaf1905	90dc2f36-7803-4077-9ffa-c33881dba242	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:05.050688	2025-11-24 16:20:05.050688
a274a18f-456a-4780-8daf-7ba1767da080	7112a886-e9b0-4e40-80ef-a73f9cba962e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/33-1763976019441-137270841.png	33.png	draft	2025-11-24 16:20:19.470606	2025-11-24 16:20:19.470606
b952fecb-4869-43ea-ab5c-c94f2c5eb5eb	c6a60793-756f-4526-8f3f-ed2f9b7703a4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:21.480867	2025-11-24 16:20:21.480867
8f48056c-a2ac-4af2-a8dc-e8d2c99cf09d	07132dd0-4bd5-4601-8a9b-6d05b87d354c	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:28.258413	2025-11-24 16:20:28.258413
519dc6fa-e76e-4417-a31a-0e3fbf42bc4a	3e76bba7-f386-4124-ba55-3eea01d1a38f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:41.652326	2025-11-24 16:20:41.652326
f8482812-2cf5-4121-a2f9-ae3cb6bb803f	bcada071-a37b-4192-8c42-afdc522c3bf3	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:44.196289	2025-11-24 16:20:44.196289
2259f5da-4bab-421a-9ed4-7c6db3174e90	29ca3068-2c31-4899-bd25-aa45f93abe93	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:51.508094	2025-11-24 16:20:51.508094
c49990bc-90bd-4719-a3a6-ce11d978f131	be878744-4347-47da-9a82-7a1dde8a1077	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	/uploads/scores/34-1763976054503-159646600.png	34.png	draft	2025-11-24 16:20:54.591363	2025-11-24 16:20:54.591363
d7c3de97-5ca4-4189-a3ca-b21cb7316c49	c79e3144-f71f-49ed-92fb-421e459bf2af	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:12.143661	2025-11-24 16:21:12.143661
9803e686-8b63-46fd-bf00-8bac392e9d8d	1463af4f-223f-4146-ae23-9a326a61ad7e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:14.278782	2025-11-24 16:21:14.278782
020c1785-cd72-4ac4-bbed-a34796119218	04ebee63-5624-4a9f-9a69-7b519ddc2bef	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:16.255479	2025-11-24 16:21:16.255479
4ec140f8-4165-478d-ad86-7065a37cdfb0	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:19.973713	2025-11-24 16:21:19.973713
d0bb6288-ea3c-4eeb-b86d-6d518dca8e1f	0797b27a-f581-418c-a1fd-4c85a8442591	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:22.882717	2025-11-24 16:21:22.882717
0ed754a1-4357-434f-b76d-83f6983820d3	12a78dac-7c82-4032-b61d-53b858b29b9d	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:37.384001	2025-11-24 16:21:37.384001
27e85aa4-24aa-40b9-95f7-c6d0ec128bb6	b5927146-8aaf-4409-8142-3f4c11c4f2b4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:39.332656	2025-11-24 16:21:39.332656
9540e761-c7c0-4154-91cc-6bb952addb8d	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:41.539404	2025-11-24 16:21:41.539404
03d7b1f5-81a2-434e-9707-d4210320a6fa	a6d07339-22c4-4da0-ab27-c3097e68cf5f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:43.973488	2025-11-24 16:21:43.973488
289d3724-e9a0-4b18-ba14-014cbec7c3bf	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:21:46.236569	2025-11-24 16:21:46.236569
d8da0471-2589-40e8-9ed2-82b696f1d1eb	d9337788-d07b-487e-a8ea-79bd9a237706	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/35-1763976109162-552981201.png	35.png	draft	2025-11-24 16:21:49.250286	2025-11-24 16:21:49.250286
e4414b40-d85a-4247-a646-45c0e2f135b6	140368b6-7511-4d5c-a434-4fb50da9f877	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:00.140905	2025-11-24 16:22:00.140905
2a453727-9cbf-4ede-8c03-76e3d01eb518	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:09.160222	2025-11-24 16:22:09.160222
99202f9e-dcf6-47ad-9549-4cd6132e167a	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:11.427876	2025-11-24 16:22:11.427876
f74f3f41-31a1-4af3-868f-350a78531911	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:13.866672	2025-11-24 16:22:13.866672
b7c2ff8c-fe66-4732-b329-8a04a805d8af	8a5ebc3d-20ee-4780-b286-64c434c87a72	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/36-1763976134360-963811198.png	36.png	draft	2025-11-24 16:22:14.445402	2025-11-24 16:22:14.445402
2314c002-2b5e-4a65-8159-5a9fe4360134	06d115ef-b738-4f1d-9a9c-9e8a0150def5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:32.366331	2025-11-24 16:22:32.366331
e871834f-177d-4a10-b021-36c0aa45fee2	95ecadd0-d137-4bfc-b69b-12cf556a467c	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:39.079789	2025-11-24 16:22:39.079789
c1114174-1942-4cf0-8a66-088eddb5b3d0	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:51.068615	2025-11-24 16:22:51.068615
d963edee-bd32-46e1-9a53-5e410b84317a	eb7bd701-5795-43cc-8391-21426990fbb5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.48	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:22:54.192304	2025-11-24 16:22:54.192304
38806b5e-4234-4f51-8708-35cb4fd69ad0	a88fb457-de23-41d1-a217-1516fc5557de	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:23:15.919505	2025-11-24 16:23:15.919505
63e8f52a-f6a2-47da-a193-059d2d6c1580	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:46.388344	2025-11-24 09:41:59.7
a0dfaaa8-1388-4bd2-a3ca-15b6ca0d6ce6	bcfac4d1-207b-4978-b551-1719db9d7ae8	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:23:31.542486	2025-11-24 10:06:46.647
bd88d7bc-77cc-40c7-95b6-3734807f4e5a	d016962d-b0c4-4e42-942f-9cad60ba440f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:23:34.909735	2025-11-24 16:23:34.909735
541d6528-d7a1-45a8-80cb-dbe297717385	20d84ee4-ac0a-4365-ad68-83359862ae69	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:23:44.983921	2025-11-24 09:23:55.653
78271216-58d1-462a-ba6e-0eaffe09e502	d1635049-c122-4492-9597-7e125fcf09f8	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/38a-1763976289369-540209048.png	38a.png	draft	2025-11-24 16:24:49.390955	2025-11-24 16:24:49.390955
8f406ed4-cbf2-4a70-a24d-f40544afc29e	d9d26ff4-1341-4c25-82e1-8ec562b829f9	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:24:54.752267	2025-11-24 16:24:54.752267
29255b9d-943a-48fa-9daf-2d89c42466c7	533ad720-b054-43ff-a802-368ec07ad8e5	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:24:59.522973	2025-11-24 16:24:59.522973
efb6394e-21e4-4be3-9a65-dfc8658034ca	f8a1368d-2826-45ab-84a2-6e25a76a3a74	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:25:07.729492	2025-11-24 16:25:07.729492
da3cd717-f060-4261-ac66-17255c301f4a	ef232bc9-a97d-46cf-b838-ea67e96b5271	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:25:15.342902	2025-11-24 16:25:15.342902
181db9c9-b282-4fb1-8222-8d71c6f45a74	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/38b-1763976326008-590362539.png	38b.png	draft	2025-11-24 16:25:26.025671	2025-11-24 16:25:26.025671
ea44ca28-4151-4c88-bace-f5a66e3bee6e	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:25:42.130555	2025-11-24 16:25:42.130555
138c6080-9ded-4827-ba26-c3f689a1035c	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:25:52.705071	2025-11-24 16:25:52.705071
d7221cca-bdcc-431b-a1ed-831da54f90c5	68a08d0e-6535-4e43-adeb-fa90fa585e59	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:26:00.215138	2025-11-24 16:26:00.215138
d2f78522-a061-498a-8507-faaaf37a5cf5	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/38c-1763976361237-618180574.png	38c.png	draft	2025-11-24 16:26:01.312085	2025-11-24 16:26:01.312085
21069b29-f09e-46c0-8350-bc4fa157e3a8	a4f478bf-d50d-4fe6-a339-de512cbbab8b	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:26:03.583213	2025-11-24 16:26:03.583213
3a7f0c8d-11fe-4f24-a221-719e5b909cb3	9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:26:08.808796	2025-11-24 16:26:08.808796
64f9d82a-efd8-47aa-be2a-661f463783b0	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:26:43.500996	2025-11-24 16:26:43.500996
9e6459e8-7a0f-428c-ae1f-ef3176d9b4aa	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:26:46.058193	2025-11-24 16:26:46.058193
4c40f942-f355-473d-a6b1-3199392eb0d6	0d874a0f-1b7a-4004-8cda-1952c40f5928	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:26:52.859835	2025-11-24 16:26:52.859835
630893eb-5b2c-4151-8149-7b156edd5fe9	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:26:58.435374	2025-11-24 16:26:58.435374
7f4664fa-d798-493f-917a-305a1f2de272	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/39-1763976422866-53362610.png	39.png	draft	2025-11-24 16:27:02.943988	2025-11-24 16:27:02.943988
cc44268c-4711-4bc9-9860-bd20c1cd4861	04d20169-ff00-42ad-b2a2-81f9adf94c2f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:27:08.900515	2025-11-24 16:27:08.900515
fe96aae5-1068-448e-b684-82c78c29540e	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	2.00	10.00	0	0	\N	6.25	6.25	\N	\N	\N	draft	2025-11-24 16:27:58.692102	2025-11-25 01:03:07.455
0a2324e7-ca04-47b3-b0d1-f5be9c690844	c981c60d-9dec-44ef-bbba-5973de4977b2	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:27:24.292785	2025-11-24 16:27:24.292785
05f56d56-c3ad-43a5-a5ce-f2b578a66302	267e5cb1-334e-4830-beb1-d94707b486bb	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:27:30.796917	2025-11-24 16:27:30.796917
22267c3a-180b-4b24-80df-44bf72db56ad	db10be95-c13b-4487-b8d2-d03a5e784e69	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/41-1763976497199-18670650.png	41.png	draft	2025-11-24 16:28:17.223433	2025-11-24 16:28:17.223433
ef82c4c3-5e17-4950-8ab6-677f1a26fd67	7112a886-e9b0-4e40-80ef-a73f9cba962e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:28:24.50823	2025-11-24 16:28:24.50823
2e320e58-fe47-458a-8374-3abbd7f74f84	db9717f5-c7a7-4532-97b1-e33f0ec86750	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/41-1763976505965-793635251.png	41.png	draft	2025-11-24 16:28:26.046483	2025-11-24 16:28:26.046483
5d176805-074e-45e1-b41e-17b88051be88	be878744-4347-47da-9a82-7a1dde8a1077	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 15:48:14.716933	2025-11-24 09:28:31.626
f924bcb3-b99d-468d-8178-eca7a35b6ad1	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/41-1763976512030-460864154.png	41.png	draft	2025-11-24 16:28:32.11846	2025-11-24 16:28:32.11846
bf69af7a-35a0-4beb-bdcf-025146b76f7e	4b68575e-b415-45b1-9338-b43937cb7a76	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:27:01.712076	2025-11-25 01:03:07.449
b389c850-20c3-4324-909f-1ff14c48e8df	c684de0e-7f27-4e91-87a3-4f5ae46156bc	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	3.00	5.00	0	0	\N	2.95	2.95	\N	\N	\N	draft	2025-11-24 16:27:17.539963	2025-11-25 01:03:07.451
14cb9522-d43f-4494-8770-f31290731e7c	165aae17-5f5b-476e-bd69-05c16e9e4c24	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	2.00	7.50	0	0	\N	7.50	7.50	\N	\N	\N	draft	2025-11-24 16:28:19.941379	2025-11-25 01:03:07.458
2a27e144-49a8-45a5-a496-05255e0e2ef6	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 16:25:57.205661	2025-11-25 01:03:07.431
ada72d8b-cfc7-46a9-b184-0cad1f9624c9	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 16:28:34.62564	2025-11-25 01:03:07.432
b6789857-5824-49f0-a07b-502319fda4e5	750d4861-d84c-4622-a0f5-e709289e603b	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/42-1763976566491-254306555.png	42.png	draft	2025-11-24 16:29:26.584888	2025-11-24 16:29:26.584888
06ad9543-388c-43b6-8b78-716d460c4e97	10392de9-00c3-4461-8c03-8b9df80b9dd1	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:30:45.507463	2025-11-24 16:30:45.507463
8b590d85-1b1f-4b8e-9366-9ff8d0e0fe5f	91f0d26e-c70a-4522-ba08-2a38cf823fd0	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:30:59.344595	2025-11-24 16:30:59.344595
8a613f5b-69da-427b-98c9-e4520d8d9bc1	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:31:05.677217	2025-11-24 16:31:05.677217
ee634561-d285-4094-9c60-80a1b74fa223	2c25c3bd-19b0-4aab-a99e-806e527815fe	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:31:12.171151	2025-11-24 16:31:12.171151
198d3009-2189-4c26-a8f5-3d507439cffa	c490447c-6617-40d5-99a1-11e57139290a	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:31:28.0785	2025-11-24 16:31:28.0785
2c2c8943-c1b4-4721-b8fd-13f21d11f58f	d9337788-d07b-487e-a8ea-79bd9a237706	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:31:28.448273	2025-11-24 16:31:28.448273
c15b4f6e-2cfa-4596-85a4-3bf5e225cf8e	8a5ebc3d-20ee-4780-b286-64c434c87a72	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:31:33.420817	2025-11-24 16:31:33.420817
d7fd43ff-5df4-454b-bb76-32dc4ef12767	593c88af-c03f-43fa-b39c-69cfc510fc20	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:31:45.31169	2025-11-24 16:31:45.31169
a99baac2-fba2-4f05-8197-95997eb78429	420e7cc2-f2ba-4fe6-8351-730fb1e2b936	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:31:50.488262	2025-11-24 16:31:50.488262
13eb53ae-fa07-41f2-aab9-67a6e5ac80df	eb7bd701-5795-43cc-8391-21426990fbb5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:06.991447	2025-11-24 16:32:06.991447
f2e24af4-8bb0-4d48-824d-374830c35c8a	88e5c0e3-6caf-4066-8851-e201c76e2ec1	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:10.811662	2025-11-24 16:32:10.811662
2b4ff161-5eee-4742-9424-37f31575d457	d1635049-c122-4492-9597-7e125fcf09f8	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:14.530174	2025-11-24 16:32:14.530174
3a58bd5d-a7eb-4968-ba46-0a8a2e2b7d1f	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:17.161034	2025-11-24 16:32:17.161034
dc38bacf-27b7-4bc5-93cf-96eca2abae09	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:18.150627	2025-11-24 16:32:18.150627
61875b40-99b2-4d16-a3d8-fa1a8f229828	e2a12005-4697-4566-91d8-fe76936856e3	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:24.139819	2025-11-24 16:32:24.139819
d2404adf-6504-4064-85a7-faf8177a6795	97ee726a-f9c6-4c65-9794-543a6feb7a1b	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/43-1763976746287-216856541.png	43.png	draft	2025-11-24 16:32:26.374848	2025-11-24 16:32:26.374848
46e7d127-c3ae-4bb1-94f9-b954cc9fb343	97186d30-1727-43b3-bd5e-685ae3cc8f78	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:32.526815	2025-11-24 16:32:32.526815
e57b2041-7ce1-4778-9091-43708259cbb1	1f752b6d-e8ff-4061-97f6-310f6fa0664b	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/44-1763976752992-681823662.png	44.png	draft	2025-11-24 16:32:33.079386	2025-11-24 16:32:33.079386
e834a762-51fa-4714-a618-a47f4a3bf28b	5da1d907-cb33-4043-b7d5-3a71d96afae6	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:36.901486	2025-11-24 16:32:36.901486
5bd5c7d2-97fe-4a0a-87ff-de8414517b1d	973abd8b-5798-4c77-912f-2f036e0e2d28	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/45-1763976759279-953396252.png	45.png	draft	2025-11-24 16:32:39.364993	2025-11-24 16:32:39.364993
d47f8920-c3bc-4829-ab39-3e977fc31e5c	a03680b8-7258-4d8f-95dc-29aaba658479	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/46-1763976765945-588396883.png	46.png	draft	2025-11-24 16:32:46.024832	2025-11-24 16:32:46.024832
40c190df-b4af-489b-b44c-f6323a6531b1	24703ccc-61d6-4e27-9325-8dd505493afb	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:32:49.577677	2025-11-24 16:32:49.577677
f22dafa4-3b29-4af1-9fe8-f0434d6af7a4	017d894c-c894-454b-8957-25be9be88d40	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:33:05.637913	2025-11-24 16:33:05.637913
d5f53525-9fc6-421d-9fff-1810f4fef676	473fb095-1711-489f-8b16-6ff5aac4f1d5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:33:28.628854	2025-11-24 16:33:28.628854
abe0bd11-2ec0-423a-ab2a-179217d23d8f	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:33:35.259316	2025-11-24 16:33:35.259316
cd76df6e-c823-4e8d-a9ac-d03608e76adb	4baf6310-700f-4a03-84e6-24d2efa70d69	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:33:43.392824	2025-11-24 16:33:43.392824
6008fe53-8f83-4482-b1a1-617e5bebf540	b5e500c7-e88c-4922-84ba-8baec799d1b3	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:33:58.854127	2025-11-24 16:33:58.854127
36b9f1c0-7fc0-441d-abc7-f5267a80cb60	4ee3df5c-a054-4b93-9f97-52a99196cdfe	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/47-1763976852748-264346019.png	47.png	draft	2025-11-24 16:32:51.75689	2025-11-24 09:34:12.766
c9ea3a5e-e059-46ec-9fcb-91b99d4102fc	23db48b5-e04d-4351-b095-bdf2defff0c4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	/uploads/scores/48-1763976860049-29192172.png	48.png	draft	2025-11-24 16:34:20.12899	2025-11-24 16:34:20.12899
8ee03ae0-19a6-42c4-b245-e908df5e66cf	d38a02ec-2612-466e-9e40-dcbf8ec952bb	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:34:38.873679	2025-11-24 16:34:38.873679
2b370fea-ec0f-4abf-ab87-a6193b53ff2a	936d4b77-3c36-4008-97fe-7742a432e046	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:34:46.038026	2025-11-24 16:34:46.038026
89008c08-0fb0-4c26-b2e5-f42670723144	a48698a9-0d29-4e15-831a-97f0b17385ac	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:35:14.393717	2025-11-24 16:35:14.393717
4563b6a9-51ec-4136-bd84-f07096a3b003	c07e54b8-588b-41c1-bee9-c4aed0726511	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:35:19.69458	2025-11-24 16:35:19.69458
a6adad96-7e97-46b2-b4ac-718e040cadc9	4caf250d-329f-4d8e-ae37-c88a914a153d	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:35:30.208241	2025-11-24 16:35:30.208241
8cb4d1eb-9d8a-41b1-833c-a87f51d62871	f05a6cc8-a921-4f10-99f5-0b5afda37328	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	/uploads/scores/49b-1763976949315-502528119.png	49b.png	draft	2025-11-24 16:35:49.405227	2025-11-24 16:35:49.405227
0a8ace41-4b20-4e15-86d4-a496e9ebfe66	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/49-1763976928258-878681021.png	49.png	draft	2025-11-24 16:35:28.337102	2025-11-24 09:35:56.706
1b61740a-e4e2-4d51-a14d-9263cbe62aef	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:36:22.324426	2025-11-24 16:36:22.324426
cb046515-6cc8-449f-abbe-27b0f14f82b0	18aaf397-5d9c-42f9-a327-fa0fba8d477d	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/49c-1763976993783-290087004.png	49c.png	draft	2025-11-24 16:36:33.819788	2025-11-24 16:36:33.819788
d8a4d10f-16d8-4e72-8484-7b074d3aad06	b3f3e20d-6661-46e8-b58b-c974643c412c	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:36:52.007589	2025-11-24 16:36:52.007589
afbc0eda-99fd-4df4-be0f-9b90b24fb7df	04fddf93-0005-43c2-bd35-ca2b965fe44b	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:37:01.154291	2025-11-24 16:37:01.154291
845d13e4-33fb-4771-9e29-b49b26a41924	c869685a-fd7e-46ed-8af6-9d8c6b74f9de	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	/uploads/scores/50-1763977025084-381938060.png	50.png	draft	2025-11-24 16:37:05.170836	2025-11-24 16:37:05.170836
ddd69b37-4393-49f5-a1b9-838ca38bc370	c8ca26c8-231d-4806-942a-afbb8a0d80c0	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:37:08.654821	2025-11-24 16:37:08.654821
47e1d8b0-efc4-426c-b937-7765ebac914c	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:37:13.318054	2025-11-24 16:37:13.318054
2be16178-fdb7-44ca-a530-027bb0ee0932	a8585392-847e-4c9c-865d-0b79bbed54f0	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:37:18.444836	2025-11-24 16:37:18.444836
bd61f6c2-9632-41d9-9878-44ea1829b031	64744f6b-59e1-4590-a3ff-78b66b9a90a7	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:37:40.980474	2025-11-24 16:37:40.980474
3c0a9f86-8023-42b0-9b7b-fed89f498be0	b487f5d9-5e12-478d-8798-f6203a871885	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:37:46.429074	2025-11-24 16:37:46.429074
ff06ac2f-4465-4807-902a-7c655c792e98	1418079e-67b7-465c-9ac3-b626ea3dfdbf	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:37:54.46403	2025-11-24 16:37:54.46403
d4195025-d3e0-41a5-8ebf-5e1092a1103d	90dc2f36-7803-4077-9ffa-c33881dba242	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:38:09.16488	2025-11-24 16:38:09.16488
aa739af1-50ac-4b89-a222-39dd3293e0e8	c6a60793-756f-4526-8f3f-ed2f9b7703a4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:38:15.486177	2025-11-24 16:38:15.486177
81b42d91-eb43-454b-9752-a98a5c53b6b8	07132dd0-4bd5-4601-8a9b-6d05b87d354c	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:38:20.017491	2025-11-24 16:38:20.017491
f82a2baa-ca5a-407d-8581-ca80f217d758	884e9fae-75d3-483c-b444-a464ac0130b9	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/51-1763977110993-951346975.png	51.png	draft	2025-11-24 16:38:31.083561	2025-11-24 16:38:31.083561
79bd42dd-325e-42cb-8ff8-c59ecd04ff1d	3e76bba7-f386-4124-ba55-3eea01d1a38f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:38:34.895215	2025-11-24 16:38:34.895215
e706ae5c-1c3c-48d9-a6f6-fbc9d447391a	ffe4c55a-155d-409f-ad66-49ed6be0ded7	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/51-1763977116437-601905231.png	51.png	draft	2025-11-24 16:38:36.525098	2025-11-24 16:38:36.525098
584b377a-2708-4aaf-849e-79d6dfa3bfd1	bcada071-a37b-4192-8c42-afdc522c3bf3	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:38:47.048494	2025-11-24 16:38:47.048494
7bb7d065-1903-42fe-84ec-24f743184302	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:38:51.366815	2025-11-24 16:38:51.366815
ceec05fd-b8c5-4685-ac85-1c4d634505da	485d3228-8245-454e-bc68-f2ce6c944263	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/52-1763977140586-970923014.png	52.png	draft	2025-11-24 16:39:00.672924	2025-11-24 16:39:00.672924
6eb1f87f-d6cf-4cf9-801a-ef464b5e2219	94b798d5-13b9-49ad-9d22-228a3f07bfb5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/52-1763977146439-29183793.png	52.png	draft	2025-11-24 16:39:06.539643	2025-11-24 16:39:06.539643
5835b410-6aeb-4193-a2bb-23468e9e4c1a	036c63d8-d0b1-412c-ac70-40bf5d359877	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:39:09.021946	2025-11-24 16:39:09.021946
17588fb5-5a3d-412b-81c5-a86da6beda11	29ca3068-2c31-4899-bd25-aa45f93abe93	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:39:22.413677	2025-11-24 16:39:22.413677
5e5f7e23-26c0-4449-b6cc-22be783cc41a	d555ced7-1211-4d31-8c05-cc44b14c20a1	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/53-1763977191782-520286379.png	53.png	draft	2025-11-24 16:39:51.868767	2025-11-24 16:39:51.868767
313cc9cc-c067-4801-9aff-a8cb08b7ca4e	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:39:55.247928	2025-11-24 16:39:55.247928
e1a54f25-da2f-4cc3-9b4b-1c5c117ec9b2	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:39:58.646656	2025-11-24 16:39:58.646656
b53038a9-ebfe-4633-9eb4-9946625d5c3e	73f03686-ee9a-4579-b3bc-3303e354e180	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:40:13.523982	2025-11-24 16:40:13.523982
a4444bb4-4e28-4f1c-8444-a62bf0d605d7	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:40:41.161408	2025-11-24 16:40:41.161408
fd28caf8-a718-4d1a-bb63-b11871c05d5c	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:40:46.508727	2025-11-24 16:40:46.508727
f89ba17e-3cf1-429d-84d1-2fdf151c1d03	246965b3-e65a-48f9-9f68-fdda80be8169	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:40:55.361944	2025-11-24 16:40:55.361944
b712bbe8-e4c5-4295-a127-256be6ca271e	5380bbd9-3b86-40ce-8597-2c87077ff5f8	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/54-1763977263760-612713709.png	54.png	draft	2025-11-24 16:41:03.856754	2025-11-24 16:41:03.856754
9849467e-3daf-4e47-aaf5-2e02beb40726	db10be95-c13b-4487-b8d2-d03a5e784e69	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:04.673621	2025-11-24 09:41:08.344
11260bc7-8926-4790-9a77-e5afb0adb3e8	2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:10.46404	2025-11-24 16:41:10.46404
d16ee3ec-b241-41da-815e-eda7c79405b1	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/54-1763977270808-308776419.png	54.png	draft	2025-11-24 16:41:10.895798	2025-11-24 16:41:10.895798
9417809a-5d23-4e11-aeee-6a903deb7268	db9717f5-c7a7-4532-97b1-e33f0ec86750	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:11.061185	2025-11-24 16:41:11.061185
9f95aae7-2831-4ff1-a2d6-16f55e832f21	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:12.910208	2025-11-24 16:41:12.910208
db5f8b96-f117-4fac-bd7b-33558571ca8a	750d4861-d84c-4622-a0f5-e709289e603b	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:21.294266	2025-11-24 16:41:21.294266
46d35f80-2584-46b1-b05d-91fd3e761bcc	97ee726a-f9c6-4c65-9794-543a6feb7a1b	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:23.943077	2025-11-24 16:41:23.943077
c9da1ddd-749d-4f7b-bc8c-434db861c834	c79e3144-f71f-49ed-92fb-421e459bf2af	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:28.811827	2025-11-24 16:41:28.811827
2d43165d-4d09-4c66-a641-2dd5463092a8	1f752b6d-e8ff-4061-97f6-310f6fa0664b	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:34.0835	2025-11-24 16:41:34.0835
5705f270-9faf-47f6-a043-c45573fca2d0	1463af4f-223f-4146-ae23-9a326a61ad7e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:34.215926	2025-11-24 16:41:34.215926
8f442f8d-4ea1-4cda-8299-a5485776dfa5	973abd8b-5798-4c77-912f-2f036e0e2d28	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:37.456798	2025-11-24 16:41:37.456798
2e02b1bd-bc11-4c25-869d-618fbc6b874f	a03680b8-7258-4d8f-95dc-29aaba658479	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:40.408143	2025-11-24 16:41:40.408143
2056f781-883b-4e2f-90c8-6c27f642697b	04ebee63-5624-4a9f-9a69-7b519ddc2bef	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:46.584598	2025-11-24 16:41:46.584598
21ad89ef-f8ad-4d0b-b796-575c6c25e9bf	4ee3df5c-a054-4b93-9f97-52a99196cdfe	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:48.540419	2025-11-24 16:41:48.540419
96b6b4d9-ac9b-491e-9959-3a42742f47ae	726d7760-d6d8-4b9c-bc15-c751fd612610	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/55-1763977313062-269799780.png	55.png	draft	2025-11-24 16:41:53.154241	2025-11-24 16:41:53.154241
23ad504d-455e-48ca-9da7-f3257bd0a7c6	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:53.877853	2025-11-24 16:41:53.877853
e93a6d52-2a57-482a-9bed-1ab5a5281868	036c63d8-d0b1-412c-ac70-40bf5d359877	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:20:48.453189	2025-11-24 09:41:56.269
8d94206c-eacc-4339-8889-cbf0d2b206b5	23db48b5-e04d-4351-b095-bdf2defff0c4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:41:56.516409	2025-11-24 16:41:56.516409
5814bf01-6609-491c-bf81-fd58f75fb1dc	0797b27a-f581-418c-a1fd-4c85a8442591	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:01.468551	2025-11-24 16:42:01.468551
8e8478c7-eef6-4bd0-9eee-a7d23d8f0ffa	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:07.02951	2025-11-24 16:42:07.02951
7628dff8-e5a6-4c92-bbb6-d88a2dce46cb	2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:20:56.116178	2025-11-24 09:42:07.241
9dd565b1-8e5b-4868-b22a-c36f682ee192	12a78dac-7c82-4032-b61d-53b858b29b9d	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:08.165624	2025-11-24 16:42:08.165624
b8194114-71b2-4e1b-9933-27f77c289797	b5927146-8aaf-4409-8142-3f4c11c4f2b4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:12.594785	2025-11-24 16:42:12.594785
fd0d128c-361c-40eb-a14d-d9f0af768102	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:17.560766	2025-11-24 16:42:17.560766
d9e89204-b2fc-4ec1-b313-81581c78b65f	f05a6cc8-a921-4f10-99f5-0b5afda37328	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:24.014379	2025-11-24 16:42:24.014379
7fec6a73-b280-49c9-a3bd-12eea5698a86	a6d07339-22c4-4da0-ab27-c3097e68cf5f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:28.14835	2025-11-24 16:42:28.14835
09678654-f907-4d71-88ba-89b7a6e37a3d	18aaf397-5d9c-42f9-a327-fa0fba8d477d	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:35.870895	2025-11-24 16:42:35.870895
29cc7b08-2b12-495f-a865-bbcb70e5fdee	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:36.658293	2025-11-24 16:42:36.658293
f9338de2-c57e-4e11-bd18-6594ee65cc2f	c869685a-fd7e-46ed-8af6-9d8c6b74f9de	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:41.401923	2025-11-24 16:42:41.401923
4c901a22-6cdf-4904-9b13-e4c9180c306d	884e9fae-75d3-483c-b444-a464ac0130b9	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:48.773542	2025-11-24 16:42:48.773542
2a59068c-4bde-444c-bea2-02c7ccbb93e1	140368b6-7511-4d5c-a434-4fb50da9f877	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:42:53.480189	2025-11-24 16:42:53.480189
3f8f7883-538f-4ac3-8657-7c944d798986	ef232bc9-a97d-46cf-b838-ea67e96b5271	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:42.448517	2025-11-24 16:46:42.448517
b4651512-fa9f-4fbb-8d63-d00709c51cb7	87dd917d-e936-49b5-8457-1a0b2ee49565	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/56-1763977376272-160059945.png	56.png	draft	2025-11-24 16:42:56.354515	2025-11-24 16:42:56.354515
9c6372b6-0e6e-4460-b693-f8d625bd3215	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:43:00.604585	2025-11-24 16:43:00.604585
817b9b7c-f8d2-4149-bc1e-e9df21eab0ce	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:43:09.160754	2025-11-24 16:43:09.160754
b7dac356-5f32-43ed-a65a-acb027e51acb	ffe4c55a-155d-409f-ad66-49ed6be0ded7	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:43:12.02395	2025-11-24 16:43:12.02395
e2f3d3c3-3110-4def-8bd8-87acd403cd17	47e1c021-cef6-4889-baa9-d824d461da1d	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/57-1763977392389-138715661.png	57.png	draft	2025-11-24 16:43:12.476751	2025-11-24 16:43:12.476751
6ca36fa3-7960-4c92-847e-3aeb020c4e24	d142142b-d819-4303-bdff-8d2c3a10e327	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/57b-1763977398941-210353761.png	57b.png	draft	2025-11-24 16:43:19.027676	2025-11-24 16:43:19.027676
7924a1d2-0f3c-4957-b5de-529073780aa3	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:43:35.755278	2025-11-24 16:43:35.755278
5100ef82-1e2a-4e81-b562-85627084cba1	06d115ef-b738-4f1d-9a9c-9e8a0150def5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:43:41.41498	2025-11-24 16:43:41.41498
83002c16-a631-49f6-8a8c-ec6681ed511c	95ecadd0-d137-4bfc-b69b-12cf556a467c	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:43:55.595225	2025-11-24 16:43:55.595225
26b0e422-353d-49c1-9faa-ebdab0055d88	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:01.989334	2025-11-24 16:44:01.989334
186cb1d8-97c3-4c9d-a950-1fb24b79ba89	a88fb457-de23-41d1-a217-1516fc5557de	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:09.100288	2025-11-24 16:44:09.100288
ff5756cf-4817-483b-b302-c614562714cd	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	9.00	0	0	\N	\N	\N	\N	/uploads/scores/58a-1763977453557-212928310.png	58a.png	draft	2025-11-24 16:44:13.641087	2025-11-24 16:44:13.641087
71249051-e8e7-425e-a20c-7c6e0b423c0a	d016962d-b0c4-4e42-942f-9cad60ba440f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:17.067663	2025-11-24 16:44:17.067663
bf5c5985-fd90-4c62-b0cc-2b9e016af9a0	485d3228-8245-454e-bc68-f2ce6c944263	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:39.856947	2025-11-24 16:44:39.856947
19affdbc-f6c3-4309-88a9-68d308a7842a	94b798d5-13b9-49ad-9d22-228a3f07bfb5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:41.960106	2025-11-24 16:44:41.960106
0b27a0a8-d65e-4b39-b95c-0f767be77a84	2161ca82-71b5-419f-bd3d-4a38216dca25	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	/uploads/scores/58b-1763977484476-591562817.png	58b.png	draft	2025-11-24 16:44:44.550429	2025-11-24 16:44:44.550429
4c7899de-31b2-4cbc-8cb4-17c34f3edc8a	d555ced7-1211-4d31-8c05-cc44b14c20a1	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:49.516015	2025-11-24 16:44:49.516015
160c8511-c5fd-40e4-b670-56daed3a9da6	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:51.36077	2025-11-24 16:44:51.36077
878eb1f6-c31f-4f47-850d-6256aa5c7bb2	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:54.809278	2025-11-24 16:44:54.809278
97ec9d0f-05a4-4f3d-9b8c-f75954381352	73f03686-ee9a-4579-b3bc-3303e354e180	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:44:58.009704	2025-11-24 16:44:58.009704
3c43e89f-5fa3-4d62-8348-994e8f1e7312	5380bbd9-3b86-40ce-8597-2c87077ff5f8	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:45:05.764359	2025-11-24 16:45:05.764359
e3d68b46-f21a-4463-9076-14032c991988	7e3203dd-6fe2-47ad-bd33-a4746782eca2	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/59-1763977509184-862476646.png	59.png	draft	2025-11-24 16:45:09.271412	2025-11-24 16:45:09.271412
09b76611-b600-4191-b194-7330aa0f7dd8	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:45:11.785387	2025-11-24 16:45:11.785387
dcc398ae-0f9e-41ed-86cf-bd59ff516ec3	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:45:23.832477	2025-11-24 16:45:23.832477
d4dd444c-345b-438f-8ee8-06bab080cad9	2161ca82-71b5-419f-bd3d-4a38216dca25	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:45:27.040182	2025-11-24 16:45:27.040182
50562a1f-fc0f-4cf4-9e8c-455c341c882f	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	15.00	0	0	\N	\N	\N	\N	/uploads/scores/60-1763977532248-983925186.png	60.png	draft	2025-11-24 16:45:32.332416	2025-11-24 16:45:32.332416
1650465b-7e0b-42ac-92eb-8621be54e217	dbfe7009-2130-49be-a36d-f80b4cc0dfe4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:45:42.347758	2025-11-24 16:45:42.347758
d1a85d75-fbe0-4e56-b716-996905912896	bcfac4d1-207b-4978-b551-1719db9d7ae8	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:45:51.419245	2025-11-24 16:45:51.419245
b92ca0d0-f41d-49ef-9363-94c3d7aabf79	20d84ee4-ac0a-4365-ad68-83359862ae69	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:02.464886	2025-11-24 16:46:02.464886
9c57b094-1f5b-4943-8968-97c47cc365c7	d9d26ff4-1341-4c25-82e1-8ec562b829f9	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:11.364381	2025-11-24 16:46:11.364381
e3f998ed-1a85-4969-bed8-09196f114865	7e3203dd-6fe2-47ad-bd33-a4746782eca2	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:24.580816	2025-11-24 16:46:24.580816
ae6d75a3-3e35-48d3-ba3a-e446b8fac4cd	533ad720-b054-43ff-a802-368ec07ad8e5	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:24.602024	2025-11-24 16:46:24.602024
e687bdb6-14bc-4bab-9778-975b4253779b	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	15.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:28.165035	2025-11-24 16:46:28.165035
9dfb4f6f-24e7-4efc-b874-1c9b86952f83	f8a1368d-2826-45ab-84a2-6e25a76a3a74	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:36.038717	2025-11-24 16:46:36.038717
118a6ae3-2680-436b-98a0-b60b29f9c9b6	3bd5a661-dabb-42a3-b7bd-62baae50f6ed	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:46:42.722123	2025-11-24 16:46:42.722123
10286fbc-6067-46ec-8d53-28edf20bded8	3bd5a661-dabb-42a3-b7bd-62baae50f6ed	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/61-1763977659537-472576544.png	61.png	draft	2025-11-24 16:47:39.556066	2025-11-24 16:47:39.556066
3870fe4c-522b-459a-b83a-65db498f6fbc	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:47:50.391185	2025-11-24 16:47:50.391185
dbd185b2-105e-4872-9ca6-5ad639338368	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:47:56.008101	2025-11-24 16:47:56.008101
1161a220-85b6-4050-bda1-4e0e160124e4	dc47d96f-a72d-417b-a156-fc743e5e2f1a	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/62-1763977682629-502083780.png	62.png	draft	2025-11-24 16:48:02.706652	2025-11-24 16:48:02.706652
b171316c-71e5-4ff6-9fea-8b060e6106bd	68a08d0e-6535-4e43-adeb-fa90fa585e59	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:48:06.450784	2025-11-24 16:48:06.450784
8774c0a8-c328-4ecf-b813-bb346c42d617	cdf9dfc9-a2db-4b12-8562-1009f500af78	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/63-1763977747853-985982301.png	63.png	draft	2025-11-24 16:49:07.877683	2025-11-24 16:49:07.877683
b988d44a-408b-42c5-b686-26fd1d113ff3	5b686276-91a2-43a8-a6fd-30e72c98f252	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/64-1763977752699-327776692.png	64.png	draft	2025-11-24 16:49:12.792681	2025-11-24 16:49:12.792681
5c131999-d20c-4c1c-befe-21817c6a4610	0c7de719-6c75-4e5f-bead-03f772c73221	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/65-1763977899470-663280490.png	65.png	draft	2025-11-24 16:51:39.506211	2025-11-24 16:51:39.506211
7a3a8413-e622-42af-9519-660eb8bdc9cc	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/66-1763977906164-757113127.png	66.png	draft	2025-11-24 16:51:46.258012	2025-11-24 16:51:46.258012
72ba2433-08fb-4ca8-8429-99cab325daf8	5546bd4e-c045-4d52-8cd6-79408f8af1a3	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/67-1763978001108-272025308.png	67.png	draft	2025-11-24 16:53:21.142034	2025-11-24 16:53:21.142034
cbf37dda-8d2e-4c0a-a244-cac81287bcf8	a5719761-6a08-41c6-99be-e1b631c41975	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/68-1763978008295-29287627.png	68.png	draft	2025-11-24 16:53:28.382437	2025-11-24 16:53:28.382437
544128e1-570e-4cdf-b505-e07159a6b852	edc3bf2f-4847-4758-81cf-6a0c84cda676	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/69-1763978014502-425639055.png	69.png	draft	2025-11-24 16:53:34.597883	2025-11-24 16:53:34.597883
a3888c03-c848-4812-b7be-8bbc728a131b	e823904a-7a2c-474e-895b-ba225efc6751	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/70-1763978027145-347753191.png	70.png	draft	2025-11-24 16:53:47.183721	2025-11-24 16:53:47.183721
3c87115c-20d6-40fb-a713-4029372909cb	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/71-1763978061469-813525068.png	71.png	draft	2025-11-24 16:54:21.49175	2025-11-24 16:54:21.49175
b505f9af-7663-4529-8cdc-acccc37c755f	53dc5a74-fab1-4942-a54f-21a5f34b45ae	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	/uploads/scores/72-1763978101133-754337225.png	72.png	draft	2025-11-24 16:55:01.167824	2025-11-24 16:55:01.167824
6c9db26d-35ee-435b-b2d7-181e7eb7b9f6	0dc41e0d-ef7f-43e7-b467-1678112877f9	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	/uploads/scores/73-1763978137203-764066914.png	73.png	draft	2025-11-24 16:55:37.311994	2025-11-24 16:55:37.311994
ac44174d-aaa5-4ccb-9668-26606e697eff	dc47d96f-a72d-417b-a156-fc743e5e2f1a	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:55:52.649032	2025-11-24 16:55:52.649032
a3da6afe-ad48-4d37-9c55-e87271fc4320	cdf9dfc9-a2db-4b12-8562-1009f500af78	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:55:58.338311	2025-11-24 16:55:58.338311
b2f4fbed-13a5-44c8-a618-d69823390f76	5b686276-91a2-43a8-a6fd-30e72c98f252	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:56:12.306694	2025-11-24 16:56:12.306694
c45d31b4-24d1-4f20-aaa5-35434f877f48	0c7de719-6c75-4e5f-bead-03f772c73221	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:56:14.687117	2025-11-24 16:56:14.687117
30f0540c-d267-4781-bdf7-7cc49ddc27ec	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:56:18.186225	2025-11-24 16:56:18.186225
5f21c399-a734-4270-9189-0c8751b8e04d	5546bd4e-c045-4d52-8cd6-79408f8af1a3	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:56:23.279573	2025-11-24 16:56:23.279573
72b800f7-d60a-466c-81be-8c3f828d6ca2	eb30a3b6-ba28-4726-b0a5-43b238720619	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	/uploads/scores/74-1763978162750-99003090.png	74.png	draft	2025-11-24 16:56:02.846845	2025-11-24 09:56:25.491
c4bd24a7-2d5c-459e-9db0-601fd3e97231	7e52a1dc-9d2b-4d67-9546-21017a044c8d	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	/uploads/scores/75-1763978217931-483442262.png	75.png	draft	2025-11-24 16:56:57.965245	2025-11-24 16:56:57.965245
544b4e87-4c5c-41dc-921b-26c2b5f0519f	a5719761-6a08-41c6-99be-e1b631c41975	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:57:29.459557	2025-11-24 16:57:29.459557
5c03efe1-929a-451c-935e-017ec21986a3	edc3bf2f-4847-4758-81cf-6a0c84cda676	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:57:32.210716	2025-11-24 16:57:32.210716
24ba9b98-96a4-4a6f-bd1a-df62b77ddcaa	e823904a-7a2c-474e-895b-ba225efc6751	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:57:50.907546	2025-11-24 16:57:50.907546
19759b35-5951-4354-af05-7bcb00468f33	3462ddf3-f516-4363-87f8-44d2ba92da64	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/76-1763978273318-647078845.png	76.png	draft	2025-11-24 16:57:53.406829	2025-11-24 16:57:53.406829
74bf9c9f-e474-43a5-b7ac-2b2d9aa1316a	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:57:57.144381	2025-11-24 16:57:57.144381
4490a7ff-200c-49a0-ba5b-6f05a9120b43	53dc5a74-fab1-4942-a54f-21a5f34b45ae	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:58:10.308388	2025-11-24 16:58:10.308388
2d5f496d-5488-4427-9fc3-07d558bd6321	0dc41e0d-ef7f-43e7-b467-1678112877f9	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:58:14.788514	2025-11-24 16:58:14.788514
700ec965-8017-4790-8fed-d816d1ca0834	eb30a3b6-ba28-4726-b0a5-43b238720619	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:58:18.053125	2025-11-24 09:58:23.629
eb43949b-ea74-4e41-843c-13836f93bde9	7244fa14-e0a5-4366-a31a-e136039445ba	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/77-1763978312121-518808646.png	77.png	draft	2025-11-24 16:58:32.199836	2025-11-24 16:58:32.199836
4bc4bbf4-ea74-4d22-9a9c-3154fc6ff748	7e52a1dc-9d2b-4d67-9546-21017a044c8d	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:58:34.50559	2025-11-24 16:58:34.50559
26651e60-a898-46c8-b8df-e941a560534d	3462ddf3-f516-4363-87f8-44d2ba92da64	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:58:38.67803	2025-11-24 16:58:38.67803
2424d562-f709-442e-bff6-60818ad12c3a	7244fa14-e0a5-4366-a31a-e136039445ba	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:58:43.71034	2025-11-24 16:58:43.71034
6f1314d0-9378-43f2-8611-b9003070f400	dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/78-1763978340010-996284708.png	78.png	draft	2025-11-24 16:59:00.030279	2025-11-24 16:59:00.030279
ac25a736-fa7e-46a5-98cc-9316d13d9a73	dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:59:08.114739	2025-11-24 16:59:08.114739
e8c0e537-39eb-4e98-b10f-5a27bc32611d	262d8859-2d57-4341-bba6-228f87871a4a	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:59:14.626658	2025-11-24 16:59:14.626658
f06a5de7-e5b2-466a-b30d-8d78ebc07e76	c2ca5e25-f355-48c5-963f-58f9abd5e319	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:59:18.224191	2025-11-24 16:59:18.224191
be3b116f-37ec-42fc-adfd-bb6ee25fec9e	432950d8-25a9-4726-b24f-6869f9c12c10	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:59:24.20001	2025-11-24 16:59:24.20001
bfa0ce7a-fd9f-4d07-a85a-0f259d415b1d	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:59:33.107794	2025-11-24 16:59:33.107794
cb112179-2dbd-413b-90f7-6e3a02951761	262d8859-2d57-4341-bba6-228f87871a4a	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/79-1763978374839-600297914.png	79.png	draft	2025-11-24 16:59:34.917989	2025-11-24 16:59:34.917989
ca192b37-d2cf-4f5e-a52b-89a62778a336	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:59:38.448626	2025-11-24 16:59:38.448626
5714f0d6-d31e-4f23-aceb-e82dec6f544e	c2ca5e25-f355-48c5-963f-58f9abd5e319	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/80-1763978382489-283016703.png	80.png	draft	2025-11-24 16:59:42.569642	2025-11-24 16:59:42.569642
0d1fe320-64f5-44eb-8031-935ea27d8617	0d874a0f-1b7a-4004-8cda-1952c40f5928	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:59:42.80864	2025-11-24 16:59:42.80864
07507da3-34bc-4e7f-bc23-d820271057e7	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 16:59:48.048444	2025-11-24 16:59:48.048444
2a11c205-87ed-45bb-9417-b12fca7056e2	432950d8-25a9-4726-b24f-6869f9c12c10	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	/uploads/scores/81-1763978419821-255515881.png	81.png	draft	2025-11-24 17:00:19.848271	2025-11-24 17:00:19.848271
1f8df9d8-a3c6-4d55-8266-6b9b699bd72c	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/82-1763978447240-840003551.png	82.png	draft	2025-11-24 17:00:47.266778	2025-11-24 17:00:47.266778
de119b79-6115-4896-8272-571498e695ff	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	/uploads/scores/83-1763978477178-917004558.png	83.png	draft	2025-11-24 17:01:17.281821	2025-11-24 17:01:17.281821
d3d8444a-c77b-4e41-af91-ac58db28324a	0d874a0f-1b7a-4004-8cda-1952c40f5928	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/84-1763978499767-484689982.png	84.png	draft	2025-11-24 17:01:39.789951	2025-11-24 17:01:39.789951
c4466547-87ae-4a23-bd0c-05551a01f180	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/85-1763978548065-582936151.png	85.png	draft	2025-11-24 17:02:28.140846	2025-11-24 17:02:28.140846
9627fd2f-af8b-4662-a515-7bc69da7a0b9	04d20169-ff00-42ad-b2a2-81f9adf94c2f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/86-1763978592439-226271226.png	86.png	draft	2025-11-24 17:03:12.463037	2025-11-24 17:03:12.463037
b26b7434-e574-49d2-ae53-907373860a6e	04d20169-ff00-42ad-b2a2-81f9adf94c2f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:03:59.495136	2025-11-24 17:03:59.495136
a4607cff-259e-4022-b92d-d674e0968b0b	10392de9-00c3-4461-8c03-8b9df80b9dd1	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:03.757214	2025-11-24 17:04:03.757214
615989b6-602f-4624-8551-82566c029afc	10392de9-00c3-4461-8c03-8b9df80b9dd1	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	/uploads/scores/87-1763978643890-25519212.png	87.png	draft	2025-11-24 17:04:03.973648	2025-11-24 17:04:03.973648
781ec091-8370-412e-adbc-3a43a0f32d17	91f0d26e-c70a-4522-ba08-2a38cf823fd0	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:08.293085	2025-11-24 17:04:08.293085
efabd083-83c0-4302-93ce-d7afa2685b99	91f0d26e-c70a-4522-ba08-2a38cf823fd0	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/88-1763978649722-721167985.png	88.png	draft	2025-11-24 17:04:09.8153	2025-11-24 17:04:09.8153
f1f65629-cf1c-4621-81cd-00e4e35c71ea	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:16.432538	2025-11-24 17:04:16.432538
e49803f3-d33e-4e6b-8491-b96129e0abf2	2c25c3bd-19b0-4aab-a99e-806e527815fe	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:18.740923	2025-11-24 17:04:18.740923
89d84afb-01f5-451f-8cc0-5d8a4d59e9cd	c490447c-6617-40d5-99a1-11e57139290a	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:26.298722	2025-11-24 17:04:26.298722
c41eef87-34a4-4967-8ae8-f7a0059611b4	593c88af-c03f-43fa-b39c-69cfc510fc20	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:40.647401	2025-11-24 17:04:40.647401
9ab6beb6-05dd-494a-a3b8-4d3189113f4b	420e7cc2-f2ba-4fe6-8351-730fb1e2b936	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:43.183296	2025-11-24 17:04:43.183296
bae86e39-391c-4a15-82de-d493099353ab	88e5c0e3-6caf-4066-8851-e201c76e2ec1	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:49.015327	2025-11-24 17:04:49.015327
fee9f932-a2ae-46d2-b851-ba892565a371	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:04:52.879206	2025-11-24 17:04:52.879206
d6092bd3-e37d-491e-8c51-c62bfb303abd	e2a12005-4697-4566-91d8-fe76936856e3	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:05:06.012457	2025-11-24 17:05:06.012457
e3d8d555-aed0-4c14-89ee-969c003d0669	97186d30-1727-43b3-bd5e-685ae3cc8f78	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:05:13.764271	2025-11-24 17:05:13.764271
25fe6603-93a7-4ef2-a039-4d0b0b715fc6	5da1d907-cb33-4043-b7d5-3a71d96afae6	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:05:16.336083	2025-11-24 17:05:16.336083
c1a574dd-60b1-4f15-b9c2-9c95399035f6	24703ccc-61d6-4e27-9325-8dd505493afb	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:05:41.099011	2025-11-24 17:05:41.099011
1fa547b1-ed8b-43af-8f47-d1da34b4131c	473fb095-1711-489f-8b16-6ff5aac4f1d5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:06:02.050362	2025-11-24 17:06:02.050362
764f3b28-251a-421f-9781-3a4ce232c917	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:06:08.142372	2025-11-24 17:06:08.142372
08a8a7fe-c4e2-44c5-b67e-fc7dee91d0dc	c490447c-6617-40d5-99a1-11e57139290a	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	/uploads/scores/91-1763978769716-59202634.png	91.png	draft	2025-11-24 17:06:09.805982	2025-11-24 17:06:09.805982
b63b3db4-6938-429a-8769-3dd39c2a320c	4baf6310-700f-4a03-84e6-24d2efa70d69	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:06:11.64264	2025-11-24 17:06:11.64264
a35f3454-0990-4723-9f93-185728d50ea3	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/89-1763978776557-171696974.png	89.png	draft	2025-11-24 17:06:16.646965	2025-11-24 17:06:16.646965
a55242ec-43b5-40af-bde1-51bb95bcc67b	b5e500c7-e88c-4922-84ba-8baec799d1b3	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:06:18.638498	2025-11-24 17:06:18.638498
c246badb-2618-4556-8a14-489787b49277	2c25c3bd-19b0-4aab-a99e-806e527815fe	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/90-1763978784601-101930171.png	90.png	draft	2025-11-24 17:06:24.683109	2025-11-24 17:06:24.683109
31d7e893-5f50-40fd-a4f8-1a9adda96da5	d38a02ec-2612-466e-9e40-dcbf8ec952bb	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:06:26.92748	2025-11-24 17:06:26.92748
d5a2c9f2-2cca-41d4-92b6-658c399ebd01	593c88af-c03f-43fa-b39c-69cfc510fc20	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/92-1763978796940-749124355.png	92.png	draft	2025-11-24 17:06:37.015066	2025-11-24 17:06:37.015066
c7d36e0d-c68a-4f3e-9d83-4fd4c1e537e3	936d4b77-3c36-4008-97fe-7742a432e046	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:06:45.63956	2025-11-24 17:06:45.63956
1f57c351-125c-4327-a6c9-bf3261951946	420e7cc2-f2ba-4fe6-8351-730fb1e2b936	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/93-1763978808634-974588199.png	93.png	draft	2025-11-24 17:06:48.71401	2025-11-24 17:06:48.71401
eb3c4e55-7130-4f3b-94f2-bc1be7c9e91b	88e5c0e3-6caf-4066-8851-e201c76e2ec1	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	/uploads/scores/94-1763978819574-863510324.png	94.png	draft	2025-11-24 17:06:59.674579	2025-11-24 17:06:59.674579
74bead3b-2578-4bb9-8097-1ed5b1a3569d	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	/uploads/scores/95-1763978828152-588850462.png	95.png	draft	2025-11-24 17:07:08.234818	2025-11-24 17:07:08.234818
cf4e55da-7dfe-447f-9bb8-efac05549dc6	dbfe7009-2130-49be-a36d-f80b4cc0dfe4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:07:36.634622	2025-11-24 17:07:36.634622
e78dc45f-5c66-417d-b70b-4ef3c99b143f	a48698a9-0d29-4e15-831a-97f0b17385ac	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:07:41.475122	2025-11-24 17:07:41.475122
0bc528ad-a69c-48d3-a32c-247ac6cf658b	e2a12005-4697-4566-91d8-fe76936856e3	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/96-1763978864473-592906816.png	96.png	draft	2025-11-24 17:07:44.558338	2025-11-24 17:07:44.558338
6f9f6d94-3163-4788-a9c0-b0ce1f730194	c07e54b8-588b-41c1-bee9-c4aed0726511	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:07:45.438093	2025-11-24 17:07:45.438093
3b6f2fe3-8772-43d8-b58f-e528af1c8298	4caf250d-329f-4d8e-ae37-c88a914a153d	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:07:49.982776	2025-11-24 17:07:49.982776
163bf251-b2fa-4a95-97c5-6cf5b2a81bee	b3f3e20d-6661-46e8-b58b-c974643c412c	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:07:55.767572	2025-11-24 17:07:55.767572
a83c03ac-f021-466e-a3d0-3c89ae52e6e2	04fddf93-0005-43c2-bd35-ca2b965fe44b	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:08:03.051951	2025-11-24 17:08:03.051951
ae27fc9f-d6fb-402d-b364-514ea5d928d7	c8ca26c8-231d-4806-942a-afbb8a0d80c0	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:08:05.959772	2025-11-24 17:08:05.959772
ecc5f7b1-510d-4fbf-8aa0-a18663654617	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:08:13.291093	2025-11-24 17:08:13.291093
577d718d-28be-4088-9169-3c1a2b7b4887	97186d30-1727-43b3-bd5e-685ae3cc8f78	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/97-1763978919225-956917519.png	97.png	draft	2025-11-24 17:08:39.250918	2025-11-24 17:08:39.250918
8aa84cce-463a-4ed6-9671-d8d191340880	5da1d907-cb33-4043-b7d5-3a71d96afae6	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/98-1763978927038-137833029.png	98.png	draft	2025-11-24 17:08:47.122998	2025-11-24 17:08:47.122998
d4bc5058-c4c1-4500-b9b6-b2ea928c47d3	24703ccc-61d6-4e27-9325-8dd505493afb	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	/uploads/scores/99-1763978937966-956195371.png	99.png	draft	2025-11-24 17:08:57.993128	2025-11-24 17:08:57.993128
e171a86b-c22c-4493-be00-f70175b28948	017d894c-c894-454b-8957-25be9be88d40	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 17:09:10.899758	2025-11-24 17:09:10.899758
83082fef-1a48-4ccb-8b7e-b580dd2551d6	a8585392-847e-4c9c-865d-0b79bbed54f0	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:09:48.644924	2025-11-24 17:09:48.644924
f0f84727-79af-4fa0-a139-34c1d299d61d	473fb095-1711-489f-8b16-6ff5aac4f1d5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/101-1763978992023-408212870.png	101.png	draft	2025-11-24 17:09:52.107153	2025-11-24 17:09:52.107153
bc1df920-8cd6-4006-b4ec-afe04d8328c8	64744f6b-59e1-4590-a3ff-78b66b9a90a7	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:09:53.245942	2025-11-24 17:09:53.245942
9cdf7b80-a3ac-4b39-a5b1-6eeb8d8a533f	b487f5d9-5e12-478d-8798-f6203a871885	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:02.097768	2025-11-24 17:10:02.097768
68fbc6d0-50a7-4657-8406-3c50a5fe92b9	1418079e-67b7-465c-9ac3-b626ea3dfdbf	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:04.764411	2025-11-24 17:10:04.764411
b4136180-1013-43f1-affa-40942e1ecc99	90dc2f36-7803-4077-9ffa-c33881dba242	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:10.814296	2025-11-24 17:10:10.814296
6bd39533-a1ee-482a-b98a-fb696c082d5a	c6a60793-756f-4526-8f3f-ed2f9b7703a4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:13.318238	2025-11-24 17:10:13.318238
3ffd219e-a8c8-497e-bf95-45ec69856aba	07132dd0-4bd5-4601-8a9b-6d05b87d354c	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:15.838343	2025-11-24 17:10:15.838343
2581877d-1a23-430c-b842-5fe81a6d74a1	3e76bba7-f386-4124-ba55-3eea01d1a38f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:18.544498	2025-11-24 17:10:18.544498
2e265828-5238-4621-96e3-af66a9bc3097	bcada071-a37b-4192-8c42-afdc522c3bf3	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:21.541523	2025-11-24 17:10:21.541523
9f7eac71-f2e0-437f-8313-795c894a46f6	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:24.629464	2025-11-24 17:10:24.629464
259a2531-35f9-4aaf-962c-67015d9414ba	036c63d8-d0b1-412c-ac70-40bf5d359877	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:10:27.037961	2025-11-24 17:10:27.037961
67637504-2cf0-4d0f-b815-0e9fb3bc52e5	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	/uploads/scores/102-1763979013630-703020595.png	102.png	draft	2025-11-24 17:10:13.711111	2025-11-24 10:10:54.681
b3be9b90-6e82-43fb-8ed2-84aa42c4259b	4baf6310-700f-4a03-84e6-24d2efa70d69	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	/uploads/scores/103-1763979059662-647356331.png	103.png	draft	2025-11-24 17:10:59.757124	2025-11-24 17:10:59.757124
0798b8b6-8c6f-4406-a4f7-17d2763be347	29ca3068-2c31-4899-bd25-aa45f93abe93	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:13.886651	2025-11-24 17:11:13.886651
8be96c0d-ca8f-42c2-8b0f-0589ab793f83	2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:15.913313	2025-11-24 17:11:15.913313
69631df0-ef14-4db0-848d-f6da9af2b634	c79e3144-f71f-49ed-92fb-421e459bf2af	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:21.695138	2025-11-24 17:11:21.695138
012f5be0-0adc-4454-8049-136ae7d579c0	1463af4f-223f-4146-ae23-9a326a61ad7e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:31.076804	2025-11-24 17:11:31.076804
b3336e24-3cc1-476b-b44f-fb708c926823	04ebee63-5624-4a9f-9a69-7b519ddc2bef	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:36.317336	2025-11-24 17:11:36.317336
43bf374b-242c-4667-92f9-fc766be76105	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:46.206429	2025-11-24 17:11:46.206429
2c17925e-b198-4184-9123-5e96906f5dbb	0797b27a-f581-418c-a1fd-4c85a8442591	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:51.114063	2025-11-24 17:11:51.114063
45b4deeb-50f9-498e-a86d-35e0d99aa797	b5e500c7-e88c-4922-84ba-8baec799d1b3	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	/uploads/scores/104-1763979113935-465720580.png	104.png	draft	2025-11-24 17:11:54.017965	2025-11-24 17:11:54.017965
195da391-6d47-4d3a-9728-b874a03d250c	12a78dac-7c82-4032-b61d-53b858b29b9d	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:11:55.155069	2025-11-24 17:11:55.155069
ff53818b-ced4-4f54-98cd-86e9e6803df7	b5927146-8aaf-4409-8142-3f4c11c4f2b4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:00.300934	2025-11-24 17:12:00.300934
99391709-c970-4328-b8c8-5cf059840981	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:04.978702	2025-11-24 17:12:04.978702
41f3ba71-0e47-4b76-b784-bf9401892580	a6d07339-22c4-4da0-ab27-c3097e68cf5f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:08.267484	2025-11-24 17:12:08.267484
8cfbb1bc-2fd5-46be-99f9-6c79f3a4cb8b	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:11.413651	2025-11-24 17:12:11.413651
4d37a857-02e4-47fb-9224-1fa7bed59116	d38a02ec-2612-466e-9e40-dcbf8ec952bb	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	/uploads/scores/105-1763979136461-705138092.png	105.png	draft	2025-11-24 17:12:16.544277	2025-11-24 17:12:16.544277
8c9a8123-7448-49b0-bcd5-d6a8802783be	140368b6-7511-4d5c-a434-4fb50da9f877	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:33.454432	2025-11-24 17:12:33.454432
c730ba74-d0a3-4bb7-948c-afffc06d20d4	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:41.600503	2025-11-24 17:12:41.600503
c7ec8a9c-2fba-4e3d-8276-07c933e2128d	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:48.896728	2025-11-24 17:12:48.896728
ba4eaccd-1c65-4bd0-a72c-b257540b84d9	936d4b77-3c36-4008-97fe-7742a432e046	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	/uploads/scores/06-1763979169825-118135022.png	06.png	draft	2025-11-24 17:12:49.906896	2025-11-24 17:12:49.906896
0bb58af8-47a8-4a50-8da4-be6c0fa2a4f8	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:12:50.516639	2025-11-24 17:12:50.516639
824174ce-46eb-4221-b715-24d670e8b9b9	a48698a9-0d29-4e15-831a-97f0b17385ac	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/107-1763979224288-416088909.png	107.png	draft	2025-11-24 17:13:44.31454	2025-11-24 17:13:44.31454
89efbbed-6fa6-433c-a32d-6ab0b0c188b4	c07e54b8-588b-41c1-bee9-c4aed0726511	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/108-1763979230158-212401302.png	108.png	draft	2025-11-24 17:13:50.252398	2025-11-24 17:13:50.252398
1dada964-f038-458b-8913-90f2ff3c9038	4caf250d-329f-4d8e-ae37-c88a914a153d	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/109-1763979234996-454555888.png	109.png	draft	2025-11-24 17:13:55.091724	2025-11-24 17:13:55.091724
a7d92ce9-67ef-40f1-8423-c965c2575af5	06d115ef-b738-4f1d-9a9c-9e8a0150def5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:14:09.8018	2025-11-24 10:14:26.671
f015c522-257a-48fb-865b-33eed596a0ab	95ecadd0-d137-4bfc-b69b-12cf556a467c	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:14:29.344811	2025-11-24 17:14:29.344811
4e9107bb-ff00-4cb8-8223-541bd069a07c	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:14:34.7452	2025-11-24 17:14:34.7452
a54ecc49-644e-4beb-b161-9fe445cb3d35	a88fb457-de23-41d1-a217-1516fc5557de	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:14:56.100663	2025-11-24 17:14:56.100663
2684b09c-29d0-40a0-8501-89bd7d90588e	b3f3e20d-6661-46e8-b58b-c974643c412c	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	/uploads/scores/110-1763979347471-504025073.png	110.png	draft	2025-11-24 17:15:47.499106	2025-11-24 17:15:47.499106
a1e6d3eb-32f6-4d0e-afee-832fbee270b3	c8ca26c8-231d-4806-942a-afbb8a0d80c0	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/112-1763979363747-839748668.png	112.png	draft	2025-11-24 17:16:03.85371	2025-11-24 17:16:03.85371
6c542be5-8b41-4adf-9b21-270cdf1eae7d	04fddf93-0005-43c2-bd35-ca2b965fe44b	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	/uploads/scores/111-1763979372344-431700652.png	111.png	draft	2025-11-24 17:15:58.095457	2025-11-24 10:16:12.416
5eaa941a-d1ab-4ade-8b17-e7da1c4c3e2d	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/113-1763979377280-177348683.png	113.png	draft	2025-11-24 17:16:17.37858	2025-11-24 17:16:17.37858
d353f454-8771-440f-8a26-535f848022d1	a8585392-847e-4c9c-865d-0b79bbed54f0	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/114-1763979389116-697335713.png	114.png	draft	2025-11-24 17:16:29.210754	2025-11-24 17:16:29.210754
acc96ed4-1868-4df2-9249-e67491836bfb	64744f6b-59e1-4590-a3ff-78b66b9a90a7	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/115-1763979393808-741063611.png	115.png	draft	2025-11-24 17:16:33.913429	2025-11-24 17:16:33.913429
3f7f0bc7-7297-4718-b991-b0cd0d2a34db	b487f5d9-5e12-478d-8798-f6203a871885	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/116-1763979459675-209165481.png	116.png	draft	2025-11-24 17:17:39.698306	2025-11-24 17:17:39.698306
1c9aff0a-fad9-4ee6-86d7-6b104a0ff5a6	1418079e-67b7-465c-9ac3-b626ea3dfdbf	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/117-1763979472161-683973211.png	117.png	draft	2025-11-24 17:17:52.245072	2025-11-24 17:17:52.245072
2c816177-e64e-4e72-a1c1-92805cbccf0f	90dc2f36-7803-4077-9ffa-c33881dba242	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/118-1763979522705-989433933.png	118.png	draft	2025-11-24 17:18:42.723363	2025-11-24 17:18:42.723363
9607be0f-181e-4fbb-a906-e286eefa92e5	d016962d-b0c4-4e42-942f-9cad60ba440f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:18:44.208053	2025-11-24 17:18:44.208053
c9deeec5-6db7-46e3-9895-7a07494fe916	c6a60793-756f-4526-8f3f-ed2f9b7703a4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/119-1763979528294-166705307.png	119.png	draft	2025-11-24 17:18:48.385285	2025-11-24 17:18:48.385285
dcc35864-0af0-4ecf-a9e3-5eac3ccdc473	dbfe7009-2130-49be-a36d-f80b4cc0dfe4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:18:52.712998	2025-11-24 17:18:52.712998
af96af50-b6e7-4a5e-aa83-39f672f3b7b0	07132dd0-4bd5-4601-8a9b-6d05b87d354c	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/120-1763979534253-573365005.png	120.png	draft	2025-11-24 17:18:54.345309	2025-11-24 17:18:54.345309
ae036724-df22-464f-abdf-cdd5d1552a90	bcfac4d1-207b-4978-b551-1719db9d7ae8	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:18:54.789562	2025-11-24 17:18:54.789562
36a9ba4a-0d08-4274-a9b1-1aaa235ebd29	20d84ee4-ac0a-4365-ad68-83359862ae69	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:19:05.437716	2025-11-24 17:19:05.437716
70385634-c991-4563-a6e7-e58ed0610c8e	d9d26ff4-1341-4c25-82e1-8ec562b829f9	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:19:13.144982	2025-11-24 17:19:13.144982
b88fcc55-4f61-442d-8614-14d32a616f0c	533ad720-b054-43ff-a802-368ec07ad8e5	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:19:19.11092	2025-11-24 17:19:19.11092
c442f3ca-0228-44db-8796-5d79397804b5	f8a1368d-2826-45ab-84a2-6e25a76a3a74	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:19:28.314815	2025-11-24 17:19:28.314815
7bfa5631-32d5-4380-b243-5808fe2d63c9	ef232bc9-a97d-46cf-b838-ea67e96b5271	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:19:37.171912	2025-11-24 17:19:37.171912
9282e567-d148-4179-a26f-64808617efd4	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:19:48.904562	2025-11-24 17:19:48.904562
0a5aeb14-746f-4bf8-b412-941f1fb17426	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:19:50.936848	2025-11-24 17:19:50.936848
e37a6206-0fdd-4afb-9683-4e881883bbaa	68a08d0e-6535-4e43-adeb-fa90fa585e59	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:20:03.754553	2025-11-24 17:20:03.754553
95d54051-5ad0-41e7-95bb-ff33ba20829b	3e76bba7-f386-4124-ba55-3eea01d1a38f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	/uploads/scores/121-1763979604203-905512377.png	121.png	draft	2025-11-24 17:20:04.286367	2025-11-24 17:20:04.286367
4db7a48f-0673-4e17-83cf-5c4b5495be94	bcada071-a37b-4192-8c42-afdc522c3bf3	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/122-1763979610857-564126837.png	122.png	draft	2025-11-24 17:20:10.94371	2025-11-24 17:20:10.94371
c3e93861-eb8f-4339-bdf1-f5420d3afcbe	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/123-1763979617652-262751842.png	123.png	draft	2025-11-24 17:20:17.73694	2025-11-24 17:20:17.73694
65527930-3b90-48a3-9b90-ce3ae8bef55b	036c63d8-d0b1-412c-ac70-40bf5d359877	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/124-1763979720023-739975385.png	124.png	draft	2025-11-24 17:22:00.129914	2025-11-24 17:22:00.129914
a197772e-38b7-4479-bc55-59bbe325195f	29ca3068-2c31-4899-bd25-aa45f93abe93	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/125-1763979727093-823725841.png	125.png	draft	2025-11-24 17:22:07.181144	2025-11-24 17:22:07.181144
9dc4752f-782a-4e5b-961c-a732c3c8c0ff	2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/126-1763979733862-352982904.png	126.png	draft	2025-11-24 17:22:13.951224	2025-11-24 17:22:13.951224
e4b915a3-74aa-4929-ba6c-99b5cbbbee74	c79e3144-f71f-49ed-92fb-421e459bf2af	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/127-1763979747477-48476281.png	127.png	draft	2025-11-24 17:22:27.503229	2025-11-24 17:22:27.503229
01abddff-b27c-40e6-972a-e107dc3da691	1463af4f-223f-4146-ae23-9a326a61ad7e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/128-1763979753892-195629643.png	128.png	draft	2025-11-24 17:22:33.978973	2025-11-24 17:22:33.978973
1285750b-d2c7-42a5-9c65-ff31a891f54f	04ebee63-5624-4a9f-9a69-7b519ddc2bef	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	/uploads/scores/129-1763979759883-268247066.png	129.png	draft	2025-11-24 17:22:39.977359	2025-11-24 17:22:39.977359
500ea195-62d1-404a-a54a-fefdbe528120	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	/uploads/scores/130-1763979767828-564284790.png	130.png	draft	2025-11-24 17:22:47.908967	2025-11-24 17:22:47.908967
ab98023a-2add-4521-a0cd-27fa79bfa492	017d894c-c894-454b-8957-25be9be88d40	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 17:05:50.27883	2025-11-24 10:23:02.104
ca1990b2-fd92-4ee8-9b9d-49b4606e6f75	0797b27a-f581-418c-a1fd-4c85a8442591	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	/uploads/scores/131-1763979855134-241831530.png	131.png	draft	2025-11-24 17:24:15.166289	2025-11-24 17:24:15.166289
adcd315c-acb7-42f0-bf7b-f329d04149a2	12a78dac-7c82-4032-b61d-53b858b29b9d	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/132-1763979861659-627133972.png	132.png	draft	2025-11-24 17:24:21.75576	2025-11-24 17:24:21.75576
83cb836f-10c5-475b-b7c6-b885fe06fe61	b5927146-8aaf-4409-8142-3f4c11c4f2b4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/133-1763979870732-598562243.png	133.png	draft	2025-11-24 17:24:30.821518	2025-11-24 17:24:30.821518
706fc647-8b0d-490e-9ba3-b45dda38671c	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/134-1763979878463-69801230.png	134.png	draft	2025-11-24 17:24:38.553392	2025-11-24 17:24:38.553392
7b4eb2ca-70ae-43a3-9781-4e4703ef3948	a6d07339-22c4-4da0-ab27-c3097e68cf5f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/135-1763979884766-370282750.png	135.png	draft	2025-11-24 17:24:44.866832	2025-11-24 17:24:44.866832
40cafd4f-352a-4457-b4ed-d483ef40ba5f	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/136-1763979890498-328927530.png	136.png	draft	2025-11-24 17:24:50.597066	2025-11-24 17:24:50.597066
80bf5512-90d4-4086-b703-f2607d69c647	140368b6-7511-4d5c-a434-4fb50da9f877	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	/uploads/scores/137-1763979896837-114794742.png	137.png	draft	2025-11-24 17:24:56.92722	2025-11-24 17:24:56.92722
14e5cd1a-7805-4163-8954-1b4b1f2cb351	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	/uploads/scores/138-1763980012429-913126663.png	138.png	draft	2025-11-24 17:26:52.468771	2025-11-24 17:26:52.468771
0444cb3c-0d5d-4839-bc48-7b14d8c491f8	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/193-1763980019056-769663238.png	193.png	draft	2025-11-24 17:26:59.144686	2025-11-24 17:26:59.144686
d9c5448e-7a65-4eb8-bb80-874813c96fbc	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/140-1763980024681-494277158.png	140.png	draft	2025-11-24 17:27:04.782564	2025-11-24 17:27:04.782564
38424a46-ceb7-4dc8-8433-556a4f117302	06d115ef-b738-4f1d-9a9c-9e8a0150def5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	/uploads/scores/141-1763980043696-286949152.png	141.png	draft	2025-11-24 17:27:23.804197	2025-11-24 17:27:23.804197
4d157084-1dd3-4f40-a8dd-0a8f522419e1	95ecadd0-d137-4bfc-b69b-12cf556a467c	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/142-1763980048855-718468487.png	142.png	draft	2025-11-24 17:27:28.958	2025-11-24 17:27:28.958
167814d8-1452-479f-abda-28a1049d85df	a88fb457-de23-41d1-a217-1516fc5557de	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/144-1763980063768-25838899.png	144.png	draft	2025-11-24 17:27:43.857637	2025-11-24 17:27:43.857637
f840bc31-1324-45b9-8b3b-5bb60c7dd599	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	/uploads/scores/143-1763980056958-790762926.png	143.png	draft	2025-11-24 17:27:37.05232	2025-11-24 10:27:50.966
c5e0dd21-1a86-42e0-bb64-d2b36d52872c	20d84ee4-ac0a-4365-ad68-83359862ae69	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/174-1763980146836-578566240.png	174.png	draft	2025-11-24 17:29:06.864936	2025-11-24 17:29:06.864936
b9ff84b0-11a0-45d8-8635-1431421265ef	bcfac4d1-207b-4978-b551-1719db9d7ae8	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/146b-1763980153841-172461956.png	146b.png	draft	2025-11-24 17:29:13.933069	2025-11-24 17:29:13.933069
d5efdec8-b208-4752-acfc-10459a79e99d	dbfe7009-2130-49be-a36d-f80b4cc0dfe4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/146-1763980160248-730127574.png	146.png	draft	2025-11-24 17:29:20.330314	2025-11-24 17:29:20.330314
4d768ee0-facc-4129-97ad-d0463b93a486	d016962d-b0c4-4e42-942f-9cad60ba440f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/145-1763980168880-137305344.png	145.png	draft	2025-11-24 17:29:28.973062	2025-11-24 17:29:28.973062
07ab2209-1360-4705-96e8-5654a5e655c4	f8a1368d-2826-45ab-84a2-6e25a76a3a74	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	/uploads/scores/150-1763980238794-93825997.png	150.png	draft	2025-11-24 17:30:38.814868	2025-11-24 17:30:38.814868
9b5f7c3a-bcad-4202-b010-cf41e5a984f5	d9d26ff4-1341-4c25-82e1-8ec562b829f9	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/148-1763980244385-473445685.png	148.png	draft	2025-11-24 17:30:44.476532	2025-11-24 17:30:44.476532
2cba71ba-4512-45b0-bab6-e229dbb3a798	533ad720-b054-43ff-a802-368ec07ad8e5	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	/uploads/scores/149-1763980249825-612526535.png	149.png	draft	2025-11-24 17:30:49.911209	2025-11-24 17:30:49.911209
00fa85ea-0d67-4897-b4ce-7342a58e7f56	ef232bc9-a97d-46cf-b838-ea67e96b5271	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:31:03.736055	2025-11-24 17:31:03.736055
39225cf2-f8c9-4ce1-9f7c-f0750863447c	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:31:13.306466	2025-11-24 17:31:13.306466
89decc60-cd2c-48b3-8982-2dcc4973b717	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	/uploads/scores/153-1763980296262-482521448.png	153.png	draft	2025-11-24 17:31:36.284466	2025-11-24 17:31:36.284466
b16ffa60-5d95-472a-9c72-faa49e7a014d	68a08d0e-6535-4e43-adeb-fa90fa585e59	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-24 17:31:40.969822	2025-11-24 17:31:40.969822
0a922ec6-70c6-442f-be76-106b14f29b20	246965b3-e65a-48f9-9f68-fdda80be8169	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	/uploads/scores/40-1763976471309-796637457.png	40.png	draft	2025-11-24 16:27:51.387928	2025-11-24 10:34:20.697
d9c439bb-3ea1-490d-8295-9c4e0a5056ca	309b57b1-e23c-41c0-9d69-175782810453	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	50.00	20.00	0	0	\N	14.74	14.74	\N	\N	\N	draft	2025-11-24 19:55:38.907959	2025-11-25 01:03:07.424
4a190c88-dc7e-4aac-bf55-793b643e0e44	a4f478bf-d50d-4fe6-a339-de512cbbab8b	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:27:33.619203	2025-11-25 03:10:42.157
349e9351-03b9-4291-bf01-cca482a63209	d2e851bc-4408-4b55-9aeb-7a551d790f09	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	50.00	0	0	\N	50.00	\N	\N	\N	\N	draft	2025-11-24 20:15:56.800369	2025-11-25 02:46:45.912
915f42a9-3830-490b-9a07-eb0f11f3b47c	b8ee94cd-6988-47b8-8e43-67193def36b6	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:16:08.359938	2025-11-25 02:46:54.717
2550eb63-349c-45d3-9691-c91f01deec16	f4bf6416-f972-4d4e-99e8-04a89fd369e2	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:16:14.947903	2025-11-25 02:46:59.697
c1d4b43c-8932-4246-810e-ad72a2954366	1b32643f-336d-42af-bb06-99423ec5e622	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:16:20.389971	2025-11-25 02:47:41.912
7737d14f-88ac-4d72-9e07-b7e925aba74b	98b52742-77b5-4a61-a42c-ab4dba2c9474	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:16:26.821233	2025-11-25 02:47:46.928
f83f269f-d6cf-4f9b-bffa-0d70ebd59daf	0665d813-c605-4a69-956f-245763cd28e9	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:16:49.763666	2025-11-25 02:48:12.118
44fa0fb1-2900-4064-85a6-2bed81da3fec	ab174e0f-5d07-4ee0-80de-58e952cfacfa	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:16:54.943859	2025-11-25 02:48:15.645
8ac8fb74-2b4a-49b8-bbc5-7acdbfe9fd1d	381a96ff-c413-4412-8b19-3c0117aea3ec	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	20.00	0	0	\N	20.00	\N	\N	\N	\N	draft	2025-11-24 20:17:26.957326	2025-11-25 02:48:50.172
5d2cd31e-577b-4804-83cf-bf6c8f88c061	cc239035-3c1b-41b2-a71a-2a43f5728543	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:17:34.391201	2025-11-25 02:49:11.17
3e7358c7-1a34-435f-a1ba-8cdfcd09b372	7313230c-811c-45e7-ba72-bc8ebcd65f7a	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:17:57.012176	2025-11-25 02:49:35.781
cbf712b6-3441-4e16-835b-ae83017e68af	d32ec9db-b64f-42c7-a21e-16a443599cf5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:18:10.341919	2025-11-25 02:49:40.425
31b037a8-deb3-4a0a-8fa8-75ea45c023b9	ef8f8ad5-2255-4292-a371-a681701526bc	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:18:17.296672	2025-11-25 02:49:53.915
00c769d7-fe10-40fc-bdee-a9dd20caf350	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:18:38.645684	2025-11-25 02:50:16.897
adf654cd-f4b9-4a47-a71e-e2b621b7c40b	8c181441-36a7-432a-a2de-2026909f9a41	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:18:42.86125	2025-11-25 02:50:20.606
dbd03db9-fd8b-4401-96c4-40f3d2ff73bf	2727281f-30a6-451a-8aa7-adf9d33434af	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:18:56.944533	2025-11-25 02:50:32.53
f853c493-527d-430f-87f7-d00c0dc6b213	02507c7a-6a42-4bdc-a8b8-79cc07d58eac	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:19:17.100339	2025-11-25 02:50:43.181
3f17b84a-d4d5-48e6-a6cb-804c8781ce10	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:19:22.123704	2025-11-25 02:51:04.025
003a53bc-2f4b-47fd-bd01-2bb34843f8e3	d574da97-c404-48bc-8ddb-1d0dd6943d04	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:19:29.072618	2025-11-25 02:51:09.982
be02abd7-2f4e-4126-aabf-0204bb48c579	fa96f655-905e-4a20-b489-8c8d3295ec83	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:19:33.89307	2025-11-25 02:51:18.637
e24286fb-f08b-46bb-814d-af778bf6c1b7	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:19:38.651832	2025-11-25 02:51:31.547
55007e74-3017-48a0-a4cb-10049ef4bc3d	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:19:48.713361	2025-11-25 02:51:42.607
acce5745-33b3-4a2f-87bd-420cff12af43	87605a36-1a09-42c9-8362-ee3f79925b46	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:19:54.347521	2025-11-25 02:54:57.946
1e6c2901-ad6c-40ed-8ddc-491bd771b760	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	4.00	10.00	0	0	\N	5.00	10.00	\N	\N	\N	draft	2025-11-24 20:27:18.621789	2025-11-25 03:07:02.77
25086f16-2db8-4e4b-b85d-3fb1a2ca40d6	9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:27:37.359031	2025-11-25 03:10:49.161
32b4ec18-06c6-4a5f-9694-53c1bea4221c	60087a36-e314-4fc1-b4d7-9aa1a33e4109	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	10.00	0	0	\N	5.00	10.00	\N	\N	\N	draft	2025-11-24 20:28:52.921809	2025-11-25 03:11:58.089
db88bcf5-f15d-4e90-ae7e-fae1ef047b6d	18aaf397-5d9c-42f9-a327-fa0fba8d477d	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 20:49:50.886331	2025-11-25 03:34:55.323
d57493e5-a3e7-41e2-89a9-fe5d9f282ae1	c684de0e-7f27-4e91-87a3-4f5ae46156bc	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	12.00	5.00	0	0	\N	5.00	5.00	\N	\N	\N	draft	2025-11-24 20:32:31.124756	2025-11-25 01:03:07.452
2f3f9b38-0441-450c-8aa1-12d0a8934e7b	f05a6cc8-a921-4f10-99f5-0b5afda37328	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:49:29.098073	2025-11-25 03:34:42.952
4dabb065-7b08-434c-9829-06323212faaf	165aae17-5f5b-476e-bd69-05c16e9e4c24	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	15.00	0	0	\N	0.00	15.00	\N	\N	\N	draft	2025-11-24 20:34:18.290011	2025-11-25 03:17:36.767
212e1fb7-1a12-4e73-80ce-e6951026586a	7112a886-e9b0-4e40-80ef-a73f9cba962e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:37:31.743657	2025-11-25 03:19:05.121
87338dec-0ec0-4755-b45f-0b849de7bc58	c981c60d-9dec-44ef-bbba-5973de4977b2	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:33:04.843216	2025-11-25 03:16:50.575
29714903-32a3-46a3-8058-137f449243ce	267e5cb1-334e-4830-beb1-d94707b486bb	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:33:16.501158	2025-11-25 03:17:02.698
d86480e2-347c-41d3-9a38-acc09af79fd7	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	10.00	0	0	\N	0.00	10.00	\N	\N	\N	draft	2025-11-24 20:33:55.612215	2025-11-25 03:17:23.69
50974247-23f5-4b6e-9889-8f6ccdf3f228	be878744-4347-47da-9a82-7a1dde8a1077	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:37:40.34031	2025-11-25 03:19:21.557
45c8f6ad-d718-4786-bdd6-c28b3ed199b3	eb7bd701-5795-43cc-8391-21426990fbb5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	3.82	\N	\N	\N	\N	draft	2025-11-24 20:38:06.106855	2025-11-25 03:21:42.763
acb6c2ce-21a8-4106-8676-7bd212e07ff0	d9337788-d07b-487e-a8ea-79bd9a237706	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:37:58.001365	2025-11-25 03:22:16.462
c406b91f-a977-4a6b-8dfb-1b985663a7a4	8a5ebc3d-20ee-4780-b286-64c434c87a72	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:38:02.392744	2025-11-25 03:22:25.424
655a2858-3438-4423-a591-68f3b413fff6	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:46:50.038959	2025-11-25 03:24:23.104
a8a1bed9-6276-45a2-b34d-352ae6ac6d7d	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:46:47.074929	2025-11-25 03:24:44.614
6731152b-a4c7-4470-a740-6e4f06b86423	d1635049-c122-4492-9597-7e125fcf09f8	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:46:38.910521	2025-11-25 03:25:06.152
df94a738-1a3a-461d-8031-ed8932141257	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:47:02.775397	2025-11-25 03:25:29.333
e134f50d-3d55-42f8-be0c-b1e6af2b020b	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 20:47:17.543273	2025-11-25 03:27:57.663
94517810-1b39-4cc3-bdc9-f3f69480d761	246965b3-e65a-48f9-9f68-fdda80be8169	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	4.00	\N	\N	\N	\N	draft	2025-11-24 20:47:42.692454	2025-11-25 03:28:50.931
49c212eb-befa-4ce3-bc4d-ac87bb70d48f	db10be95-c13b-4487-b8d2-d03a5e784e69	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:47:52.412651	2025-11-25 03:29:07.809
c41ff013-2a9e-4aa4-9894-35c96f0d1d40	db9717f5-c7a7-4532-97b1-e33f0ec86750	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:47:55.44938	2025-11-25 03:29:14.306
d8fe48f7-b67d-44fa-b8c6-3fd8e2cdc041	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.50	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:48:09.706899	2025-11-25 03:31:27.605
cbced995-be84-4d8f-b274-4f16096c22e2	750d4861-d84c-4622-a0f5-e709289e603b	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:48:17.293054	2025-11-25 03:32:40.685
d5ff2825-b89e-4126-908f-444d9555bd0f	97ee726a-f9c6-4c65-9794-543a6feb7a1b	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:48:21.463474	2025-11-25 03:33:14.785
0ad35b2b-7fb0-4952-8eed-be35ff21daf4	1f752b6d-e8ff-4061-97f6-310f6fa0664b	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:48:34.026545	2025-11-25 03:33:29.949
27b9daff-bdf0-4f18-b9c5-d0ae5daa69df	973abd8b-5798-4c77-912f-2f036e0e2d28	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:48:41.220744	2025-11-25 03:33:37.016
4c22c672-1838-4c50-9bfe-4e27c72bf65f	a03680b8-7258-4d8f-95dc-29aaba658479	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:48:56.910474	2025-11-25 03:33:42.954
62458874-03d7-481c-9132-bb8e141a91f5	4ee3df5c-a054-4b93-9f97-52a99196cdfe	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:49:11.862242	2025-11-25 03:33:49.654
e9aa5748-f77b-41c1-988e-33f39c9e173c	23db48b5-e04d-4351-b095-bdf2defff0c4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	8.00	\N	\N	\N	\N	draft	2025-11-24 20:49:21.070127	2025-11-25 03:34:27.073
1e99b849-7ff8-421c-b7da-ccdbe69b7c43	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 20:49:25.770075	2025-11-25 03:34:34.401
96f69e31-d568-48a9-b9a5-1501b5307ac0	c869685a-fd7e-46ed-8af6-9d8c6b74f9de	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	4.00	\N	\N	\N	\N	draft	2025-11-24 20:49:59.152545	2025-11-25 03:35:14.614
89525cc9-ef0a-4f62-a2bf-35ca00a77e69	884e9fae-75d3-483c-b444-a464ac0130b9	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:51:12.519803	2025-11-25 03:35:30.977
6ef43e98-2877-4324-83f6-02675a981ff3	ffe4c55a-155d-409f-ad66-49ed6be0ded7	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:51:18.093882	2025-11-25 03:35:44.191
69d4b9c6-2731-41be-a674-4a23fe9c3659	485d3228-8245-454e-bc68-f2ce6c944263	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:51:22.509614	2025-11-25 03:35:56.621
0def1a46-d4e3-4074-a1f3-212bd86677fe	94b798d5-13b9-49ad-9d22-228a3f07bfb5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:51:29.450805	2025-11-25 03:36:04.787
b5293685-4292-4dc5-85eb-159873c3dbdc	eb30a3b6-ba28-4726-b0a5-43b238720619	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 21:02:27.469394	2025-11-24 14:02:56.187
50021f80-9d94-4f5d-82e6-76dd1f2106f3	d555ced7-1211-4d31-8c05-cc44b14c20a1	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:51:38.040612	2025-11-25 03:36:43.703
8771bad2-0dc6-4fa8-a467-a568b29849f8	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:51:41.180896	2025-11-25 03:36:51.091
4e242ae8-603e-4bcc-9cbd-9ea53f8ab2e9	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:51:43.716792	2025-11-25 03:37:09.095
66f962fa-8be4-4f40-ba9b-f53fbb453a9c	73f03686-ee9a-4579-b3bc-3303e354e180	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:52:06.225465	2025-11-25 03:37:18.653
ddd63516-3b3b-4deb-be78-35abc6ed3b1b	5380bbd9-3b86-40ce-8597-2c87077ff5f8	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:52:14.642698	2025-11-25 03:38:50.476
659ccb12-a4aa-4dbb-b105-2224f8f5e579	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:52:17.990609	2025-11-25 03:38:58.735
7b0b7352-6a1e-4c26-8506-1c190cab491f	726d7760-d6d8-4b9c-bc15-c751fd612610	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:53:18.345959	2025-11-25 03:39:13.391
b5aaf036-b48f-4407-97be-adac29ae3b8a	87dd917d-e936-49b5-8457-1a0b2ee49565	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:53:24.401371	2025-11-25 03:40:05.648
5065e5f9-dd26-423e-a2a9-89a50b00af33	47e1c021-cef6-4889-baa9-d824d461da1d	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:54:25.004666	2025-11-25 03:42:11.384
184125ac-7dbb-4eb7-bcc1-7cc9fccf96c7	d142142b-d819-4303-bdff-8d2c3a10e327	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:54:39.004646	2025-11-25 03:42:27.439
c65aad94-0eb1-4b2a-82b1-fbdb20ea2d54	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:54:52.603007	2025-11-25 03:42:46.793
8503f58e-3f09-4a95-b22e-36c0500cf367	2161ca82-71b5-419f-bd3d-4a38216dca25	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 20:54:57.275016	2025-11-25 03:43:25.037
bb29bcb9-d9b9-4e8f-a118-21cfcfd83d7f	7e3203dd-6fe2-47ad-bd33-a4746782eca2	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:55:20.480669	2025-11-25 03:43:52.814
36003fe1-a983-4dc6-9ac8-538e633dda87	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	15.00	0	0	\N	15.00	\N	\N	\N	\N	draft	2025-11-24 20:55:32.114022	2025-11-25 03:44:14.847
11e4b8eb-6e8d-4b70-9d3d-c02212944169	3bd5a661-dabb-42a3-b7bd-62baae50f6ed	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:55:42.772322	2025-11-25 03:44:21.358
b28480e6-65bc-4c32-b430-9c7223b91f37	dc47d96f-a72d-417b-a156-fc743e5e2f1a	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:55:53.648835	2025-11-25 03:44:33.128
743d2ea3-d23b-43e6-9586-9362ae3ba015	cdf9dfc9-a2db-4b12-8562-1009f500af78	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:56:07.66964	2025-11-25 03:44:44.284
25b2c136-f977-48be-b62e-3561a924de2f	5b686276-91a2-43a8-a6fd-30e72c98f252	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:56:36.654238	2025-11-25 03:44:49.426
c1a562b9-f5df-4940-85a0-3e2ac58debe6	0c7de719-6c75-4e5f-bead-03f772c73221	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:56:43.313396	2025-11-25 03:44:56.723
967c4207-ff6e-48d4-84b1-281a80e293b1	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:57:08.567234	2025-11-25 03:45:10.573
23367b37-dbce-4241-bc07-e3a6b1eb2218	5546bd4e-c045-4d52-8cd6-79408f8af1a3	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 20:57:16.338072	2025-11-25 03:45:25.552
9163c87a-673a-4894-a9d3-0126adbfa7d2	a5719761-6a08-41c6-99be-e1b631c41975	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:57:19.853945	2025-11-25 03:45:34.554
e24e6aa9-b2ef-4a3d-a3cd-1044efa1c6c0	edc3bf2f-4847-4758-81cf-6a0c84cda676	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 20:57:23.998774	2025-11-25 03:45:39.872
d4f7095f-2bc7-461d-aca4-f832d0835a9b	e823904a-7a2c-474e-895b-ba225efc6751	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:01:42.378501	2025-11-25 03:45:57.724
da108722-8611-4b9c-beea-07f20f94cf6b	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:01:45.638613	2025-11-25 03:46:06.746
0d7acc79-94f0-447d-b5df-847ef344f7c7	53dc5a74-fab1-4942-a54f-21a5f34b45ae	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	1.50	\N	\N	\N	\N	draft	2025-11-24 21:01:50.884482	2025-11-25 03:46:23.981
c855d00e-5fe0-4cb2-95fa-8b6da8184725	0dc41e0d-ef7f-43e7-b467-1678112877f9	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	1.50	\N	\N	\N	\N	draft	2025-11-24 21:01:55.100086	2025-11-25 03:46:38.363
1f4a4d46-25df-4a7e-8c9b-8b315d47e606	7e52a1dc-9d2b-4d67-9546-21017a044c8d	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	0.50	\N	\N	\N	\N	draft	2025-11-24 21:02:32.495567	2025-11-25 03:46:49.239
ba782c59-f216-46a1-b53d-7b5725762888	3462ddf3-f516-4363-87f8-44d2ba92da64	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:02:37.168682	2025-11-25 03:46:59.2
15aa8292-2577-4e99-a7f3-1aee94a6423d	7244fa14-e0a5-4366-a31a-e136039445ba	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:02:41.3267	2025-11-25 03:47:10.569
53c17973-9971-4e92-862f-5e5f70348df9	dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:03:07.913931	2025-11-25 03:47:16.889
4a689c1c-4aa1-413c-a8b6-81074192939d	262d8859-2d57-4341-bba6-228f87871a4a	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:03:10.958023	2025-11-25 03:47:25.497
c81d14d0-3b6c-4fc7-ad11-b84262792121	432950d8-25a9-4726-b24f-6869f9c12c10	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	4.00	\N	\N	\N	\N	draft	2025-11-24 21:03:30.973984	2025-11-25 03:47:37.311
0002b054-3f3d-43de-bdad-7e7f480bf0a8	04d20169-ff00-42ad-b2a2-81f9adf94c2f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:04:20.012672	2025-11-25 03:48:30.577
bfab0e17-c5d8-413f-99b5-5f66cd9554d1	4b68575e-b415-45b1-9338-b43937cb7a76	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	5.00	0	0	\N	0.00	5.00	\N	\N	\N	draft	2025-11-24 20:31:30.318381	2025-11-25 03:16:25.984
3a15171d-9c37-46ae-8a01-a90f126a89d9	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:03:39.442468	2025-11-25 03:47:50.984
5c78a157-e6e7-4788-9b12-d2ac00850b78	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	5.00	0	0	\N	0.00	5.00	\N	\N	\N	draft	2025-11-24 20:30:38.476251	2025-11-25 03:14:50.366
648248af-6fe3-4e41-924c-2638380b61ce	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	5.00	0	0	\N	0.00	5.00	\N	\N	\N	draft	2025-11-24 20:30:59.52694	2025-11-25 03:15:35.226
528e170b-e8ae-461a-8585-b6e7b27e9b61	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 21:03:44.944271	2025-11-25 03:48:02.063
d4207ae2-d79f-4521-9768-7b261534c5bf	0d874a0f-1b7a-4004-8cda-1952c40f5928	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:03:49.928293	2025-11-25 03:48:08.299
252073c2-de5e-4f00-b9dd-60e962eabb05	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:03:57.132706	2025-11-25 03:48:22.388
7ebbedac-fce5-4ba2-b806-4447cc7246b9	10392de9-00c3-4461-8c03-8b9df80b9dd1	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:04:25.64785	2025-11-25 03:48:44.027
083e22a4-cd44-4bb4-8c5d-09599b86111f	91f0d26e-c70a-4522-ba08-2a38cf823fd0	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:04:29.033978	2025-11-25 03:48:50.545
5a6de92f-dbdc-4236-9e26-c398b0624bde	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:04:32.529758	2025-11-25 03:48:58.186
21a25245-3420-4aa8-8fbb-ca84eac51366	2c25c3bd-19b0-4aab-a99e-806e527815fe	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:04:36.428283	2025-11-25 03:49:15.519
a9b0bd75-5e57-4c34-a0e4-cfdeb7f9b7e7	c490447c-6617-40d5-99a1-11e57139290a	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:04:43.246545	2025-11-25 03:50:49.789
a7fc99ac-a45a-48a2-89f1-d8ba7d7ecc8c	593c88af-c03f-43fa-b39c-69cfc510fc20	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:04:58.941963	2025-11-25 03:50:57.905
b1a45166-5568-455b-9a29-76c3e89c119d	420e7cc2-f2ba-4fe6-8351-730fb1e2b936	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:05:05.711642	2025-11-25 03:51:02.875
8dd9af87-bad9-4d10-8e48-b80cb3bb9405	88e5c0e3-6caf-4066-8851-e201c76e2ec1	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	0.75	\N	\N	\N	\N	draft	2025-11-24 21:05:14.061801	2025-11-25 03:51:16.207
d41736c0-0d99-4cb6-a07f-8325a1e9bbf0	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:05:21.479811	2025-11-25 03:51:26.431
d107af59-12a5-4f2b-a855-88f651276da3	e2a12005-4697-4566-91d8-fe76936856e3	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:05:28.607985	2025-11-25 03:51:35.422
96da02c8-f1ae-4c67-9597-920d656e8ee7	97186d30-1727-43b3-bd5e-685ae3cc8f78	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:05:32.031858	2025-11-25 03:51:41.295
da5923f5-3352-4e23-9167-18bb1eb3a1ec	5da1d907-cb33-4043-b7d5-3a71d96afae6	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:05:36.948592	2025-11-25 03:51:48.271
a94eee88-dd8f-44dc-90ce-fca333f714da	24703ccc-61d6-4e27-9325-8dd505493afb	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:14:19.568948	2025-11-25 03:52:29.071
9ceb2118-31b1-434d-bfc1-840f3f72e106	473fb095-1711-489f-8b16-6ff5aac4f1d5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:14:37.682456	2025-11-25 03:53:04.337
e13e5ee7-3816-4ed6-9490-9032eb39192b	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	8.00	\N	\N	\N	\N	draft	2025-11-24 21:15:14.099349	2025-11-25 03:53:48.744
7fcbc44e-24aa-4abb-b36b-abb381b75d3f	4baf6310-700f-4a03-84e6-24d2efa70d69	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	8.00	\N	\N	\N	\N	draft	2025-11-24 21:15:19.583202	2025-11-25 03:54:21.588
c1856f92-f9f1-4365-ac80-7b644b4c0303	b5e500c7-e88c-4922-84ba-8baec799d1b3	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	8.00	\N	\N	\N	\N	draft	2025-11-24 21:15:57.755508	2025-11-25 03:54:44.469
c9d151d9-97cb-4d64-a424-79edfe00c4d2	d38a02ec-2612-466e-9e40-dcbf8ec952bb	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	8.00	\N	\N	\N	\N	draft	2025-11-24 21:16:12.473191	2025-11-25 03:55:17.431
1e556a7c-56b3-423e-841b-e7fba2ce1b60	936d4b77-3c36-4008-97fe-7742a432e046	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	8.00	\N	\N	\N	\N	draft	2025-11-24 21:16:22.109478	2025-11-25 03:55:42.602
ea88933b-c85a-461c-9130-d2c2f77c64c7	a48698a9-0d29-4e15-831a-97f0b17385ac	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:16:32.340627	2025-11-25 03:55:55.11
21abe17b-33b1-480f-9041-c230dda33804	c07e54b8-588b-41c1-bee9-c4aed0726511	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:16:36.044076	2025-11-25 03:56:05.051
94ba4f8f-9df7-4968-b507-5c167970e289	4caf250d-329f-4d8e-ae37-c88a914a153d	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:16:53.127929	2025-11-25 03:56:09.358
c5b390fd-0158-49e7-bd68-b208848a95da	b3f3e20d-6661-46e8-b58b-c974643c412c	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 21:16:56.332859	2025-11-25 03:56:13.012
53fdfc62-42dc-4227-8e45-290ad7ce1f0e	04fddf93-0005-43c2-bd35-ca2b965fe44b	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 21:17:01.074646	2025-11-25 03:56:27.747
edaac495-dbb3-4c5a-91a7-3776ce64d059	c8ca26c8-231d-4806-942a-afbb8a0d80c0	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:17:04.834038	2025-11-25 03:56:35.221
66cdcf98-b516-48f0-acae-24557f2975e3	12a78dac-7c82-4032-b61d-53b858b29b9d	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:19:03.02444	2025-11-25 04:00:40.802
4fe3d2bd-0b49-44e1-aded-976f66ba6336	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 21:19:17.543268	2025-11-25 04:01:32.782
f85af35c-c5c5-4efa-96cb-ad4b40dfe315	95ecadd0-d137-4bfc-b69b-12cf556a467c	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	8.00	\N	\N	\N	\N	draft	2025-11-24 21:20:04.131555	2025-11-25 04:02:22.681
e849a720-5850-4f4f-ba2e-a7a77b1576ab	a88fb457-de23-41d1-a217-1516fc5557de	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 21:20:18.306375	2025-11-24 14:20:23.536
112a355a-8470-4d14-8888-8862422e89e5	a8585392-847e-4c9c-865d-0b79bbed54f0	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:17:16.549249	2025-11-25 03:57:02.832
7f129b5e-8ee2-4234-bd89-ffa4dec3479b	64744f6b-59e1-4590-a3ff-78b66b9a90a7	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:17:31.880936	2025-11-25 03:57:09.036
6f635139-71c0-4cba-83ec-060c2fe74b41	b487f5d9-5e12-478d-8798-f6203a871885	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:17:43.294591	2025-11-25 03:57:17.89
2f866840-a11d-4531-9611-4c1cb89cefc3	1418079e-67b7-465c-9ac3-b626ea3dfdbf	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:17:46.005424	2025-11-25 03:57:28.97
04697877-a110-41fa-85a8-1621dcfb1b7e	90dc2f36-7803-4077-9ffa-c33881dba242	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:17:48.381169	2025-11-25 03:57:44.713
e5fc4623-6aed-4032-97f4-847556eed44f	c6a60793-756f-4526-8f3f-ed2f9b7703a4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:17:52.589179	2025-11-25 03:57:53.745
25d949c5-4182-4da4-8dff-308bb9718127	07132dd0-4bd5-4601-8a9b-6d05b87d354c	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:17:56.637214	2025-11-25 03:58:01.681
f556e18f-6f22-4502-a036-15a76c572ae4	3e76bba7-f386-4124-ba55-3eea01d1a38f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:17:59.333205	2025-11-25 03:58:14.408
c86c8b70-ee6b-4ae6-b67a-eba2c025f53d	bcada071-a37b-4192-8c42-afdc522c3bf3	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	1.00	\N	\N	\N	\N	draft	2025-11-24 21:18:02.06137	2025-11-25 03:58:24.905
dfbe7cd0-f76f-45ed-8f89-8aa172a7f75b	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:18:04.516399	2025-11-25 03:58:32.467
9ba3de1b-e47e-4011-8f15-a4527c8f8d3f	036c63d8-d0b1-412c-ac70-40bf5d359877	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:18:07.061211	2025-11-25 03:59:05.806
644e8963-6968-4b3d-848e-6f04f65a29d4	29ca3068-2c31-4899-bd25-aa45f93abe93	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:18:34.200349	2025-11-25 03:59:18.507
83d1e707-b823-4340-b707-ea5bcf4a601d	2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:18:38.598224	2025-11-25 03:59:28.926
0110f009-8714-439d-b60b-ae7625224b21	c79e3144-f71f-49ed-92fb-421e459bf2af	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:18:43.262142	2025-11-25 03:59:39.13
b03af7cb-4dd6-481b-bd5f-156b54daa7ac	1463af4f-223f-4146-ae23-9a326a61ad7e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:18:45.918112	2025-11-25 03:59:47.351
5e330321-d381-4099-98c8-f01ee4f351aa	04ebee63-5624-4a9f-9a69-7b519ddc2bef	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 21:18:48.928121	2025-11-25 04:00:01.555
a132102e-397a-44de-a156-7694ad7d873d	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	1.50	\N	\N	\N	\N	draft	2025-11-24 21:18:54.295331	2025-11-25 04:00:16.139
7cbdb8d5-9f8c-4e62-8d49-3cece69071c5	0797b27a-f581-418c-a1fd-4c85a8442591	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	1.50	\N	\N	\N	\N	draft	2025-11-24 21:18:58.49229	2025-11-25 04:00:29.267
9c3867ec-5ebf-4982-a75f-dab79ac1763b	b5927146-8aaf-4409-8142-3f4c11c4f2b4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:19:05.070443	2025-11-25 04:00:46.857
77872971-0ba1-4cca-85b5-cfc63cd6db93	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:19:06.903372	2025-11-25 04:00:53.706
1ca1a6a4-6df6-489d-9924-7927f2b7855f	a6d07339-22c4-4da0-ab27-c3097e68cf5f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:19:08.863688	2025-11-25 04:01:07.845
82fae6e0-fcd6-404d-9da3-efd025877a8c	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:19:10.943264	2025-11-25 04:01:14.237
b3eb517e-9ced-4cc2-9b6d-e49da44abce6	140368b6-7511-4d5c-a434-4fb50da9f877	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 21:19:13.799431	2025-11-25 04:01:25.382
8d5279be-c7a5-46c6-ae57-a100b637e1ec	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:19:21.159393	2025-11-25 04:01:46.767
91a652af-dec8-4c9d-81aa-48d1f4a39a4f	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:19:23.823416	2025-11-25 04:01:54.345
7ac705a6-0bf6-4278-bfb3-d60472af17cb	06d115ef-b738-4f1d-9a9c-9e8a0150def5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	10.00	\N	\N	\N	\N	draft	2025-11-24 21:19:46.409218	2025-11-25 04:02:11.008
807069d8-df44-4588-a58c-d57a793728a5	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:20:13.022737	2025-11-25 04:02:59.402
cb0d1d7a-19b5-4645-b2a4-d31830dfe80a	d016962d-b0c4-4e42-942f-9cad60ba440f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:22:07.304296	2025-11-25 04:03:24.504
421800c7-efe3-4845-ae76-333b3d30570b	dbfe7009-2130-49be-a36d-f80b4cc0dfe4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:22:16.224544	2025-11-25 04:03:33.087
f4487572-4e7b-4a8b-998a-51bb77da53a3	bcfac4d1-207b-4978-b551-1719db9d7ae8	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:22:19.356437	2025-11-25 04:03:40.326
6215bb8f-c2dd-4a20-92ff-6dd8a4ba4944	c2ca5e25-f355-48c5-963f-58f9abd5e319	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 21:03:15.367957	2025-11-24 14:37:08.378
ae794ad8-7595-49a0-a808-e5a41ecefbe4	60087a36-e314-4fc1-b4d7-9aa1a33e4109	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:41:44.110811	2025-11-25 01:03:07.436
72601a84-b325-43d4-b490-d4ecc6b84c2b	60087a36-e314-4fc1-b4d7-9aa1a33e4109	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:55:29.672381	2025-11-25 01:03:07.436
984072b4-c7d1-4450-a4d8-8db8e1cb8911	5620079f-e61f-4e50-8571-a5c2dd9de71e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 16:12:18.503282	2025-11-25 01:03:07.417
1d5a849a-083b-410a-ba6f-00eb8979aa25	5620079f-e61f-4e50-8571-a5c2dd9de71e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	10.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 20:22:51.084569	2025-11-25 01:03:07.418
d8061d14-6927-49ba-af0e-ebcf52d69ac9	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 20:21:59.590034	2025-11-25 01:03:07.421
d2f2cf6f-4e1e-4aac-854c-580170585996	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:29:29.552101	2025-11-25 01:03:07.422
e4393960-a086-4b46-a23b-70f5f8e7bc28	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 16:09:16.907214	2025-11-25 01:03:07.422
66b5e379-5a01-40ae-be60-54403025b4ec	309b57b1-e23c-41c0-9d69-175782810453	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	20.00	0	0	\N	20.00	20.00	\N	\N	\N	draft	2025-11-24 16:28:06.418512	2025-11-25 01:03:07.425
bd06b2b0-46e2-42be-8e15-1d060db5b1f0	600a025b-0c42-4f27-9475-0316676f584c	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	5.00	0	0	\N	0.00	5.00	\N	\N	\N	draft	2025-11-24 20:29:35.262017	2025-11-25 03:14:02.076
0f83a104-199d-4ec4-a378-90ce125876e7	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	10.00	10.00	\N	\N	\N	draft	2025-11-24 16:15:12.041606	2025-11-25 01:03:07.433
18390538-e15a-49cf-87a0-cdd0aa61efdb	20d84ee4-ac0a-4365-ad68-83359862ae69	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:22:25.969189	2025-11-25 04:03:59.905
331ef06a-2aa7-4c35-843f-a29bb397b9c4	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:34:57.75422	2025-11-25 01:03:07.446
898f83f6-bccd-463b-86a6-410a4a1a399e	c684de0e-7f27-4e91-87a3-4f5ae46156bc	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	2.50	0	0	\N	2.50	2.50	\N	\N	\N	draft	2025-11-24 15:57:30.156045	2025-11-25 01:03:07.452
c6700dcc-f865-4f4c-b1db-b61fee990c25	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-24 15:58:08.446279	2025-11-25 01:03:07.456
5ec8a898-0627-46f0-a4e0-c4d41e7ff60b	d2e851bc-4408-4b55-9aeb-7a551d790f09	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	50.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:37:39.388227	2025-11-25 08:37:39.388227
0961aa06-7252-4b68-b5cc-bdc863cd6196	b8ee94cd-6988-47b8-8e43-67193def36b6	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:39:22.642651	2025-11-25 08:39:22.642651
f5090da1-cc43-45e7-8658-90fbfdb90c3d	f4bf6416-f972-4d4e-99e8-04a89fd369e2	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:39:33.123918	2025-11-25 08:39:33.123918
e586459b-9814-4da1-910d-0ab3ecae0a0d	1b32643f-336d-42af-bb06-99423ec5e622	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:40:27.826991	2025-11-25 08:40:27.826991
e5a64d37-98fb-44dc-9192-85f1779ffa55	98b52742-77b5-4a61-a42c-ab4dba2c9474	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:40:39.219875	2025-11-25 08:40:39.219875
c2ca4cc2-adac-4755-b0f8-b244dff58383	0665d813-c605-4a69-956f-245763cd28e9	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:41:10.705948	2025-11-25 08:41:10.705948
63e06e27-d915-4bef-b389-eef6f9ab4cb6	ab174e0f-5d07-4ee0-80de-58e952cfacfa	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:41:18.201503	2025-11-25 08:41:18.201503
6b2feb21-2fd8-4917-b8b4-0381dec1c8b4	381a96ff-c413-4412-8b19-3c0117aea3ec	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	20.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:54:28.368371	2025-11-25 08:54:28.368371
493f9a91-5867-4547-93df-4f5328522f64	cc239035-3c1b-41b2-a71a-2a43f5728543	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:56:53.648879	2025-11-25 08:56:53.648879
7c2c0b5c-a44e-46dc-a96e-a9134df42ef3	7313230c-811c-45e7-ba72-bc8ebcd65f7a	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:57:36.037811	2025-11-25 08:57:36.037811
1ee3b9a5-5ba0-42ad-9e4f-d1e6cc747ed6	d32ec9db-b64f-42c7-a21e-16a443599cf5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:57:45.34619	2025-11-25 08:57:45.34619
4b9be422-4ede-47d4-8722-6152b348300b	ef8f8ad5-2255-4292-a371-a681701526bc	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:57:53.522897	2025-11-25 08:57:53.522897
8df82975-ed01-4620-9a83-5293daddc8e3	d9d26ff4-1341-4c25-82e1-8ec562b829f9	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:22:34.617467	2025-11-25 04:04:08.909
37b6d9c1-ff7d-4d07-b9c5-d100f062e798	533ad720-b054-43ff-a802-368ec07ad8e5	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	5.00	\N	\N	\N	\N	draft	2025-11-24 21:22:39.021988	2025-11-25 04:04:16.507
2e6db100-cde6-4760-8327-5d527cc9f6db	f8a1368d-2826-45ab-84a2-6e25a76a3a74	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:23:12.991306	2025-11-25 04:06:51.438
54d2186f-c196-4065-833d-a0be5fbceecb	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	3.00	\N	\N	\N	\N	draft	2025-11-24 21:23:30.355174	2025-11-25 04:08:26.124
a1337635-cfd4-480d-8624-d4d614c6c1a8	ef232bc9-a97d-46cf-b838-ea67e96b5271	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:23:21.706225	2025-11-25 04:08:45.119
e0bbf8fd-0c9e-4a3e-85b3-8126851e6658	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:23:37.690526	2025-11-25 04:09:07.698
ba6f6528-6f21-43af-86be-1f31ca11da8c	68a08d0e-6535-4e43-adeb-fa90fa585e59	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	\N	\N	\N	\N	draft	2025-11-24 21:23:46.066992	2025-11-25 04:09:15.583
003dc64a-92e7-49f2-85a5-08701d6ee7f1	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:58:09.215319	2025-11-25 08:58:09.215319
ca0833f0-34c3-4029-bf7f-9e993086922f	8c181441-36a7-432a-a2de-2026909f9a41	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:58:22.571581	2025-11-25 08:58:22.571581
72ea094b-4bef-4be6-bf4b-6e12799a1aeb	2727281f-30a6-451a-8aa7-adf9d33434af	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:58:35.420448	2025-11-25 08:58:35.420448
80e20ce6-2685-43f6-90de-8f629b9395b9	02507c7a-6a42-4bdc-a8b8-79cc07d58eac	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:58:53.30944	2025-11-25 08:58:53.30944
d48b1f24-e184-4663-af13-8e53ee9f8469	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:59:11.823228	2025-11-25 08:59:11.823228
0e658944-f4be-493a-98cf-510b2e31be49	d574da97-c404-48bc-8ddb-1d0dd6943d04	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:59:23.077301	2025-11-25 08:59:23.077301
e8332b52-8c2b-466e-814c-a7081a411720	fa96f655-905e-4a20-b489-8c8d3295ec83	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:59:33.554142	2025-11-25 08:59:33.554142
3ef7b7a9-40d1-4c6b-8fb8-e38b083bc8ff	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:59:45.515593	2025-11-25 08:59:45.515593
791833a7-0fef-49cc-860c-559b61a3c8c8	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 08:59:58.286784	2025-11-25 08:59:58.286784
88185e82-f9ea-4b05-b8b0-3da08bea6fde	87605a36-1a09-42c9-8362-ee3f79925b46	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:00:08.983853	2025-11-25 09:00:08.983853
1eb04cc8-e1bf-4b08-a322-7fec4b069e99	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:03:56.910396	2025-11-25 09:03:56.910396
69d70f5f-4541-42f7-adb4-cc37dce4cd2c	a4f478bf-d50d-4fe6-a339-de512cbbab8b	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:08:08.928405	2025-11-25 09:08:08.928405
71bc94e8-e89a-4fdc-81aa-309743aa3b82	9cb99902-1bb1-4a86-bdc1-d41b5b4696ba	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:08:17.244495	2025-11-25 09:08:17.244495
7b44c3fb-fb87-4202-9fd1-8955584cddba	60087a36-e314-4fc1-b4d7-9aa1a33e4109	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:08:45.205907	2025-11-25 09:08:45.205907
5da46b03-3b17-4b5e-ba87-0485b6e57176	600a025b-0c42-4f27-9475-0316676f584c	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:16:12.281008	2025-11-25 09:16:12.281008
9d5ece26-b45e-4d0d-a527-1c3b952b78dd	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:16:34.668782	2025-11-25 09:16:34.668782
aff8b553-c4cd-4bdb-9c59-279f85017755	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:17:16.008894	2025-11-25 09:17:16.008894
37b07b2e-3443-4a29-9cb8-6f15faa2eb4d	4b68575e-b415-45b1-9338-b43937cb7a76	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:17:57.223673	2025-11-25 09:17:57.223673
c4c96a42-31e6-4c64-864b-8c2e1f76dadf	c684de0e-7f27-4e91-87a3-4f5ae46156bc	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:18:05.026099	2025-11-25 09:18:05.026099
99f40248-da07-4e41-b727-5ad1769e6478	c981c60d-9dec-44ef-bbba-5973de4977b2	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:18:13.237558	2025-11-25 09:18:13.237558
04baf2c9-99aa-4944-86c7-67e6ad25743f	267e5cb1-334e-4830-beb1-d94707b486bb	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:18:36.811171	2025-11-25 09:18:36.811171
ad878dbd-a28e-4c5b-a0ed-bdc11e5028f4	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	10.00	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:19:09.985527	2025-11-25 09:19:09.985527
691c52f3-3a08-4f64-95d1-d52aaac664c7	165aae17-5f5b-476e-bd69-05c16e9e4c24	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:21:22.603915	2025-11-25 09:21:22.603915
09d51553-9ef5-450a-a66f-457be11e6710	7112a886-e9b0-4e40-80ef-a73f9cba962e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:21:37.277625	2025-11-25 09:21:37.277625
e98ab441-ec90-4e37-a9f3-f87afd77d929	be878744-4347-47da-9a82-7a1dde8a1077	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:22:04.404298	2025-11-25 09:22:04.404298
8cfdded1-caf5-4a0a-bf88-c44dfacc6f53	d9337788-d07b-487e-a8ea-79bd9a237706	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:22:18.541939	2025-11-25 09:22:18.541939
e2dbcd6f-8ce6-4d9d-b419-15d5a9353731	8a5ebc3d-20ee-4780-b286-64c434c87a72	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:22:30.250348	2025-11-25 09:22:30.250348
e4df8994-e86e-402c-9c87-00a128f92848	eb7bd701-5795-43cc-8391-21426990fbb5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:22:46.640936	2025-11-25 09:22:46.640936
b760a551-9d19-44d1-81e9-17192b88e0fd	d1635049-c122-4492-9597-7e125fcf09f8	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:23:06.517289	2025-11-25 09:23:06.517289
2ec6b1fb-c1e4-419e-9f5b-af27c7591300	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:23:13.822889	2025-11-25 09:23:13.822889
67ec22f4-ee16-49ff-8549-da5015db239a	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:23:55.537276	2025-11-25 09:23:55.537276
42806ef5-1ffb-46e9-af63-b49c0fe5e3be	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:24:15.719474	2025-11-25 09:24:15.719474
29edc7c3-1008-4d8a-bd48-bce859b9ff14	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	100.00	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:07:54.961043	2025-11-25 03:27:09.676
f66fe8e6-c428-4526-9b68-c2fcee7f9cfa	309b57b1-e23c-41c0-9d69-175782810453	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	50.00	20.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:06:38.952682	2025-11-25 03:27:41.073
2de8eb8b-4354-440b-8e73-16fc4ebf643a	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:24:28.448888	2025-11-25 09:24:28.448888
6539a790-5d8e-48ed-a868-d1fc95d7a0b9	246965b3-e65a-48f9-9f68-fdda80be8169	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:24:42.605832	2025-11-25 09:24:42.605832
9d12ed17-dc44-4f93-ab25-dd7a80630283	db9717f5-c7a7-4532-97b1-e33f0ec86750	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:25:03.050203	2025-11-25 09:25:03.050203
aefd1ce8-12e0-4d65-acb1-ffc0ffddd6a2	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:25:16.523832	2025-11-25 02:25:32.581
22bb2adc-c0d8-43fc-9dfe-7a737e508ae3	750d4861-d84c-4622-a0f5-e709289e603b	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:25:58.317789	2025-11-25 09:25:58.317789
7136fb30-ee96-4948-a33c-2db1d16073e5	97ee726a-f9c6-4c65-9794-543a6feb7a1b	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:26:05.727184	2025-11-25 09:26:05.727184
156b980c-5a20-40cf-8128-fb7bfeb03f4c	1f752b6d-e8ff-4061-97f6-310f6fa0664b	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:26:16.66972	2025-11-25 02:26:31.681
ad911511-6e19-457b-bb74-80b6f73dee63	973abd8b-5798-4c77-912f-2f036e0e2d28	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-25 09:26:48.104653	2025-11-25 02:27:31.347
3e90819b-a120-498a-9b73-3572d9523805	a03680b8-7258-4d8f-95dc-29aaba658479	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:27:39.534643	2025-11-25 09:27:39.534643
487c496d-c1e6-4d17-9478-150f2d817834	4ee3df5c-a054-4b93-9f97-52a99196cdfe	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:27:46.509835	2025-11-25 09:27:46.509835
32b82d8c-2d95-4f4d-aa25-5dab7b8d1941	23db48b5-e04d-4351-b095-bdf2defff0c4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:28:07.756138	2025-11-25 09:28:07.756138
7743fb2c-c7c3-4176-bcdb-5c2e07325876	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:29:06.644895	2025-11-25 09:29:06.644895
75ab8165-2cc7-45c2-abf6-ecb1ccfc34e8	f05a6cc8-a921-4f10-99f5-0b5afda37328	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:29:16.879429	2025-11-25 09:29:16.879429
83d664a8-784c-4129-90a1-1ae1ad42bb1e	18aaf397-5d9c-42f9-a327-fa0fba8d477d	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:29:30.604825	2025-11-25 09:29:30.604825
5dbb1829-1221-41d0-9569-a5a5f7211e55	c869685a-fd7e-46ed-8af6-9d8c6b74f9de	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:29:39.63821	2025-11-25 09:29:39.63821
54b04624-2c50-4e4f-bf3d-cdd4c7963ed6	884e9fae-75d3-483c-b444-a464ac0130b9	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:30:24.328516	2025-11-25 09:30:24.328516
557e59fa-22b4-4745-9255-1efd675a87a5	ffe4c55a-155d-409f-ad66-49ed6be0ded7	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:30:32.209748	2025-11-25 09:30:32.209748
ad5deb7a-0422-4c74-a73f-6599fc2bae62	485d3228-8245-454e-bc68-f2ce6c944263	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:30:44.285077	2025-11-25 09:30:44.285077
b28c07ba-2170-4a6c-992a-c1ac1a38155c	94b798d5-13b9-49ad-9d22-228a3f07bfb5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:31:05.384776	2025-11-25 09:31:05.384776
6ffb82d5-2120-4fd2-87be-93047b6006e7	d555ced7-1211-4d31-8c05-cc44b14c20a1	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:31:19.790456	2025-11-25 09:31:19.790456
d7c66112-da0e-4a09-81a3-12d8d7036601	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:31:42.00508	2025-11-25 09:31:42.00508
e05dd59f-ea39-4687-b111-9575aa361ab5	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:31:50.183762	2025-11-25 09:31:50.183762
8128d2ee-98dc-45c8-91bb-708a169c9e8c	73f03686-ee9a-4579-b3bc-3303e354e180	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:31:59.376693	2025-11-25 09:31:59.376693
1bbb2a27-89f6-4a6b-bc05-2682e9471fd5	5380bbd9-3b86-40ce-8597-2c87077ff5f8	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:32:15.859923	2025-11-25 09:32:15.859923
bf1951d4-6bbd-42d4-a2f8-197e92221252	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:32:21.973428	2025-11-25 09:32:21.973428
89f776ab-39ee-44ca-a2e5-63adb70a9aa9	726d7760-d6d8-4b9c-bc15-c751fd612610	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:32:35.188698	2025-11-25 09:32:35.188698
9862e882-2612-484a-bcab-450a7f44728d	87dd917d-e936-49b5-8457-1a0b2ee49565	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:35:58.646893	2025-11-25 09:35:58.646893
4da25455-3d40-4011-bba2-f386ebacf97a	47e1c021-cef6-4889-baa9-d824d461da1d	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:36:41.674008	2025-11-25 09:36:41.674008
f3b7251b-cd43-4a2d-aed8-c3a5efc61fc6	d142142b-d819-4303-bdff-8d2c3a10e327	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:37:02.906816	2025-11-25 09:37:02.906816
4cfcbf82-9ee7-4fad-a714-9cfd71d48000	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:37:17.162184	2025-11-25 09:37:17.162184
143d0015-8e92-4c75-ad02-2c77aebe013c	2161ca82-71b5-419f-bd3d-4a38216dca25	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:37:37.431421	2025-11-25 09:37:37.431421
387ac1f9-4f18-4968-90e0-a5bb1076a5a3	7e3203dd-6fe2-47ad-bd33-a4746782eca2	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:38:17.425803	2025-11-25 09:38:17.425803
158d2be0-bb02-40d0-b002-e78f3a134f0b	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	15.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:38:40.606779	2025-11-25 09:38:40.606779
d32b7b9b-d588-4b4c-a198-c752fcd084ae	3bd5a661-dabb-42a3-b7bd-62baae50f6ed	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:38:55.41032	2025-11-25 09:38:55.41032
75616a9a-99e6-4f08-aabe-4681b3818a71	dc47d96f-a72d-417b-a156-fc743e5e2f1a	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:39:27.827887	2025-11-25 09:39:27.827887
1a2eeda6-4101-4cf2-87c7-f61e7b998dd8	cdf9dfc9-a2db-4b12-8562-1009f500af78	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:39:37.386296	2025-11-25 09:39:37.386296
d8fc75a1-470d-4c30-b014-20aa92aadbe5	5b686276-91a2-43a8-a6fd-30e72c98f252	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:39:54.134842	2025-11-25 09:39:54.134842
2dc12074-25f7-491e-a150-1657e602d0b1	0c7de719-6c75-4e5f-bead-03f772c73221	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:40:01.225249	2025-11-25 09:40:01.225249
fcbdf03d-dbc1-415d-b0c7-28c77fb54985	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:40:12.707157	2025-11-25 09:40:12.707157
de3dc256-490e-4803-b42f-a3ab5fdeb784	5546bd4e-c045-4d52-8cd6-79408f8af1a3	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:40:23.839372	2025-11-25 09:40:23.839372
9a048e5b-a096-44cf-ae9a-ebfac0565dd5	a5719761-6a08-41c6-99be-e1b631c41975	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:40:32.937788	2025-11-25 09:40:32.937788
d0e44a76-45ae-43dc-895e-0226eff7221a	edc3bf2f-4847-4758-81cf-6a0c84cda676	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:40:59.462688	2025-11-25 09:40:59.462688
e7bb413b-82dd-40e4-ade4-d44bd7871d7b	e823904a-7a2c-474e-895b-ba225efc6751	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:41:18.273452	2025-11-25 09:41:18.273452
b341adc5-ceb2-4ad2-8fd4-45df921d5d22	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:41:47.608104	2025-11-25 09:41:47.608104
99fa9367-134c-478e-b2fc-3c94e7c9c282	53dc5a74-fab1-4942-a54f-21a5f34b45ae	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:42:28.017032	2025-11-25 09:42:28.017032
5a4c1af2-755c-43b0-8868-7740ac48652b	0dc41e0d-ef7f-43e7-b467-1678112877f9	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:42:53.183309	2025-11-25 09:42:53.183309
33c11562-4ee6-49fc-ab72-49bde70f35be	eb30a3b6-ba28-4726-b0a5-43b238720619	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:43:18.76618	2025-11-25 09:43:18.76618
81c29ad5-9639-4841-b819-27e4aea4e590	7e52a1dc-9d2b-4d67-9546-21017a044c8d	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:43:47.783745	2025-11-25 09:43:47.783745
64bd50d2-993b-4e41-ae84-d90866b557f4	3462ddf3-f516-4363-87f8-44d2ba92da64	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:44:11.683681	2025-11-25 09:44:11.683681
b5c6b9d4-6d8c-4248-8c55-74959e563961	7244fa14-e0a5-4366-a31a-e136039445ba	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:44:20.418148	2025-11-25 09:44:20.418148
b4f54f69-6c7a-450d-8769-8418fc3ff46d	dd5600cf-6977-4c3f-a2e4-5ff5ad5651b5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:44:34.13619	2025-11-25 09:44:34.13619
748a8ff6-da28-44ff-92a9-3351b3987b3d	262d8859-2d57-4341-bba6-228f87871a4a	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:44:42.80199	2025-11-25 09:44:42.80199
97de1ecf-f1a7-4abe-8b97-6a9d062338f5	c2ca5e25-f355-48c5-963f-58f9abd5e319	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	0.00	0.00	\N	\N	\N	draft	2025-11-25 09:45:45.990102	2025-11-25 09:45:45.990102
e5e1b4f4-b4f5-4746-adcc-7c7f321a98fd	432950d8-25a9-4726-b24f-6869f9c12c10	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	4.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:46:08.697805	2025-11-25 09:46:08.697805
cdc9c17e-9951-4f1f-bdb3-66090e482f9c	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:46:17.912053	2025-11-25 09:46:17.912053
bf5a6cc3-b589-4b95-8dc4-0702bc92257b	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:46:29.612283	2025-11-25 09:46:29.612283
5c99bb1d-aa0c-492a-9904-de660a5c4f08	0d874a0f-1b7a-4004-8cda-1952c40f5928	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:46:41.6915	2025-11-25 09:46:41.6915
b462128f-63cc-4062-ba54-2fbb622d42bd	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:46:49.091389	2025-11-25 09:46:49.091389
0c64d772-f587-4777-912c-a942f2cfa0b4	04d20169-ff00-42ad-b2a2-81f9adf94c2f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:47:09.738769	2025-11-25 09:47:09.738769
73697161-c806-418e-b626-d26c96f30a1d	10392de9-00c3-4461-8c03-8b9df80b9dd1	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:47:20.457625	2025-11-25 09:47:20.457625
a9f563ac-3735-4791-999e-36441053bd9e	91f0d26e-c70a-4522-ba08-2a38cf823fd0	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:47:40.249422	2025-11-25 09:47:40.249422
a305db0f-12cb-4c8b-8ca0-da646afb4e0f	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:48:02.177942	2025-11-25 09:48:02.177942
d8befbc9-0ad3-4669-8b37-f5fc51d5ffdb	2c25c3bd-19b0-4aab-a99e-806e527815fe	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:48:09.332637	2025-11-25 09:48:09.332637
c63a0115-e60c-4e93-ac8e-69526f42896f	c490447c-6617-40d5-99a1-11e57139290a	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:48:22.019509	2025-11-25 09:48:22.019509
1f68e0e4-e1e6-44c1-9ab9-9df7253f316e	593c88af-c03f-43fa-b39c-69cfc510fc20	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:48:32.018965	2025-11-25 09:48:32.018965
6bda87fd-d584-45f0-a077-398b8ff30677	420e7cc2-f2ba-4fe6-8351-730fb1e2b936	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:48:55.389696	2025-11-25 09:48:55.389696
a093bde9-c950-4879-8189-d19304df4180	88e5c0e3-6caf-4066-8851-e201c76e2ec1	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.75	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:49:14.236774	2025-11-25 09:49:14.236774
ca5ebe8b-d3e3-48e9-bf62-50bd2ffcc388	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:49:23.805285	2025-11-25 09:49:23.805285
60e5c096-7425-4b37-92b1-5c9a16d80df8	e2a12005-4697-4566-91d8-fe76936856e3	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:49:35.677523	2025-11-25 09:49:35.677523
884a2755-998b-4fc2-b69b-3d29e06c85a0	97186d30-1727-43b3-bd5e-685ae3cc8f78	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:49:43.83865	2025-11-25 09:49:43.83865
78464ed0-c71c-4ac3-99e6-bd8dd1e92995	24703ccc-61d6-4e27-9325-8dd505493afb	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:50:00.850484	2025-11-25 09:50:00.850484
9833fa9a-49e9-4557-884b-b75e817e7701	5da1d907-cb33-4043-b7d5-3a71d96afae6	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:50:23.514762	2025-11-25 09:50:23.514762
6a080e2e-27c5-4b4f-b51c-6a37192e05d3	473fb095-1711-489f-8b16-6ff5aac4f1d5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:51:16.993064	2025-11-25 09:51:16.993064
d7aa133d-60a6-4086-9cd8-6c00f7b59de5	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:51:45.379189	2025-11-25 09:51:45.379189
860da723-ad7f-4448-8645-b6f8e77aa2cb	4baf6310-700f-4a03-84e6-24d2efa70d69	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:51:54.804423	2025-11-25 09:51:54.804423
55af7526-78bf-4c1d-8450-33a899ddae9b	b5e500c7-e88c-4922-84ba-8baec799d1b3	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:52:12.600689	2025-11-25 09:52:12.600689
6a0199b7-dc42-4ecd-a3de-b3bff54c140d	d38a02ec-2612-466e-9e40-dcbf8ec952bb	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:52:22.405411	2025-11-25 09:52:22.405411
ca4df67c-4599-4737-8531-4d556ee47630	936d4b77-3c36-4008-97fe-7742a432e046	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	8.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:52:48.611535	2025-11-25 09:52:48.611535
0a196ae2-fcbb-4875-9836-aec4b0e8f0d0	a48698a9-0d29-4e15-831a-97f0b17385ac	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:53:12.727947	2025-11-25 09:53:12.727947
0abeab72-9045-4601-9f03-c43b54789abd	c07e54b8-588b-41c1-bee9-c4aed0726511	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:53:26.5211	2025-11-25 09:53:26.5211
a13f4296-fd03-4efd-8661-c7832cc54f99	4caf250d-329f-4d8e-ae37-c88a914a153d	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:53:39.409116	2025-11-25 09:53:39.409116
7518c92d-903d-4cab-89da-f7fa036eec44	b3f3e20d-6661-46e8-b58b-c974643c412c	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:53:47.52567	2025-11-25 09:53:47.52567
cfe3d3eb-ab2d-40c7-92c3-f75806e0b274	04fddf93-0005-43c2-bd35-ca2b965fe44b	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:54:08.12995	2025-11-25 09:54:08.12995
6a9ccb95-70c8-4e2b-9027-72d46268abba	c8ca26c8-231d-4806-942a-afbb8a0d80c0	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:54:28.181495	2025-11-25 09:54:28.181495
fcfa8976-7f5f-40c8-928d-c3d801011daf	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:54:42.431456	2025-11-25 09:54:42.431456
71ab0c81-9662-4c69-a606-a1d9c3c1047e	a8585392-847e-4c9c-865d-0b79bbed54f0	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:54:49.780826	2025-11-25 09:54:49.780826
d788d7de-0a84-4fcd-8d16-cf7cdc77d2bc	64744f6b-59e1-4590-a3ff-78b66b9a90a7	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:54:57.427736	2025-11-25 09:54:57.427736
0f0b181b-3e9b-41c2-8e88-b01950c6e9ee	b487f5d9-5e12-478d-8798-f6203a871885	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:55:06.614759	2025-11-25 09:55:06.614759
84f6fbb6-145d-465b-be71-94cae49aaf20	1418079e-67b7-465c-9ac3-b626ea3dfdbf	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:55:15.532687	2025-11-25 09:55:15.532687
ca8490ed-1bf0-4edf-9cdb-0c5def3df9a3	90dc2f36-7803-4077-9ffa-c33881dba242	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:55:34.923088	2025-11-25 09:55:34.923088
ce531713-15f6-4819-b7e9-f3410280b74f	c6a60793-756f-4526-8f3f-ed2f9b7703a4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:55:42.669043	2025-11-25 09:55:42.669043
df042f32-3992-4f52-9db7-73e340186635	07132dd0-4bd5-4601-8a9b-6d05b87d354c	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:55:52.924025	2025-11-25 09:55:52.924025
06f402dc-4cc4-4cc2-943e-8461907060c1	3e76bba7-f386-4124-ba55-3eea01d1a38f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:56:00.004147	2025-11-25 09:56:00.004147
4589dbbb-e962-4cc7-bd1a-dea0a21bbe3c	bcada071-a37b-4192-8c42-afdc522c3bf3	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:56:06.77305	2025-11-25 09:56:06.77305
8001b048-9d3e-48aa-8c60-816b41a1980c	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:56:19.674191	2025-11-25 09:56:19.674191
ed043dc0-490d-41d8-8be5-1593a0c354f3	29ca3068-2c31-4899-bd25-aa45f93abe93	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:57:20.405821	2025-11-25 09:57:20.405821
80c75637-562c-42b4-b41f-ae5669cc300e	2dfc85a4-9e4d-4dd8-881d-e8defe2115bc	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:57:30.278293	2025-11-25 09:57:30.278293
ae96a8ad-37fe-4c49-98b8-b8bf422de878	c79e3144-f71f-49ed-92fb-421e459bf2af	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:57:35.842208	2025-11-25 09:57:35.842208
9a18e3b1-cbb0-4361-a670-cf3ebbd5875d	1463af4f-223f-4146-ae23-9a326a61ad7e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:57:44.373072	2025-11-25 09:57:44.373072
5d623910-8049-4fec-9d8f-43606b93891f	04ebee63-5624-4a9f-9a69-7b519ddc2bef	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:58:00.311798	2025-11-25 09:58:00.311798
7f0355db-fbcc-4ab7-9a6b-fe3550a87919	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:58:11.800752	2025-11-25 09:58:11.800752
4855349c-48db-496a-b147-a8af98284231	0797b27a-f581-418c-a1fd-4c85a8442591	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:58:19.518873	2025-11-25 09:58:19.518873
3ea5602c-d659-461f-bc93-378bfac2bcfd	12a78dac-7c82-4032-b61d-53b858b29b9d	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:58:28.589663	2025-11-25 09:58:28.589663
4bf972b7-deec-4804-9ca8-1758544ccea3	b5927146-8aaf-4409-8142-3f4c11c4f2b4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:58:38.813018	2025-11-25 09:58:38.813018
8446c6bd-377b-4c8f-b46c-04026be64843	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:58:49.25169	2025-11-25 09:58:49.25169
335e5be9-d9b6-4657-9ace-ac59e5d1b9eb	a6d07339-22c4-4da0-ab27-c3097e68cf5f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:58:54.973638	2025-11-25 09:58:54.973638
af8ca6f3-abf5-4f10-a93a-333a19ab8189	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:59:03.756972	2025-11-25 09:59:03.756972
8a69db2b-cb80-4aac-b4fa-1ac718e9ad57	140368b6-7511-4d5c-a434-4fb50da9f877	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	3.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:59:09.662617	2025-11-25 09:59:09.662617
410e92a2-87ee-48e2-a20d-12a74f824861	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:59:39.097774	2025-11-25 09:59:39.097774
d8f7bd26-68a8-4d9b-a034-b3b8d3690291	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:59:45.345734	2025-11-25 09:59:45.345734
cb360166-6850-4d4f-b65f-df7d03d58d0b	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:59:54.485168	2025-11-25 09:59:54.485168
eb6a03eb-3089-44ce-891c-5d409a23f31c	06d115ef-b738-4f1d-9a9c-9e8a0150def5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	10.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:00:50.927702	2025-11-25 10:00:50.927702
4b7402ce-a379-4a13-833a-f67794679fa3	95ecadd0-d137-4bfc-b69b-12cf556a467c	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:01:09.15552	2025-11-25 10:01:09.15552
ac0a988c-be29-49b8-9f8f-4bb878212928	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:01:23.16572	2025-11-25 10:01:23.16572
c5cfc98b-e803-407e-931b-c77a574ca86a	a88fb457-de23-41d1-a217-1516fc5557de	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:01:34.07494	2025-11-25 10:01:34.07494
0cda7fea-fb51-4d0f-b3f4-4d876f2e69d9	d016962d-b0c4-4e42-942f-9cad60ba440f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:01:47.027513	2025-11-25 10:01:47.027513
5f381e32-d449-42da-a0a0-b498d18e65ba	dbfe7009-2130-49be-a36d-f80b4cc0dfe4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:02:12.050181	2025-11-25 10:02:12.050181
d5326212-8f1b-493a-b516-ec0caef630c9	bcfac4d1-207b-4978-b551-1719db9d7ae8	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:02:22.837449	2025-11-25 10:02:22.837449
57f3b52d-c517-4a20-91cd-d3ec94bd7408	20d84ee4-ac0a-4365-ad68-83359862ae69	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:02:48.734425	2025-11-25 10:02:48.734425
a1b9f7e2-cc40-48ec-8d0f-02e8dea82744	d9d26ff4-1341-4c25-82e1-8ec562b829f9	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:02:59.765225	2025-11-25 10:02:59.765225
0f2829f4-72a5-4fb6-b7c5-6cf3b38979f2	533ad720-b054-43ff-a802-368ec07ad8e5	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	5.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:03:15.953588	2025-11-25 10:03:15.953588
25da5dac-ef20-4dd4-a770-e5a38e49502c	f8a1368d-2826-45ab-84a2-6e25a76a3a74	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	2.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:03:33.945682	2025-11-25 10:03:33.945682
642fb49d-5f4b-47a2-b979-5e1f3c737142	ef232bc9-a97d-46cf-b838-ea67e96b5271	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.50	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:03:46.327327	2025-11-25 10:03:46.327327
d730d095-5940-47e2-b071-b5644a7bde80	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:04:04.800454	2025-11-25 10:04:04.800454
20cae50c-0bf4-43f3-b7de-628546451ecb	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:04:11.787556	2025-11-25 10:04:11.787556
7b8faa6f-4c0d-4bd8-89e8-a1c4193f740c	68a08d0e-6535-4e43-adeb-fa90fa585e59	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	\N	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 10:05:26.907364	2025-11-25 10:05:26.907364
be7d6f08-acef-4299-b70c-950653095145	5620079f-e61f-4e50-8571-a5c2dd9de71e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	0.00	0	0	\N	\N	\N	\N	\N	\N	draft	2025-11-25 09:02:40.80567	2025-11-25 03:10:08.049
b30a6d41-0f51-4620-8b34-3c38a078f627	309b57b1-e23c-41c0-9d69-175782810453	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	4.00	20.00	0	0	\N	0.00	20.00	\N	\N	\N	draft	2025-11-24 21:29:59.011293	2025-11-25 03:12:16.611
e8c0d26a-4f7a-40e2-8b5b-c70eca0bba13	017d894c-c894-454b-8957-25be9be88d40	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	0.00	\N	Không có hội phụ nữ, không giao chỉ tiêu, không chấm điểm	\N	\N	draft	2025-11-24 21:14:23.447757	2025-11-25 03:52:39.177
eb1b46be-ce22-4a65-8a6d-f6e95af92d1d	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	\N	1.00	0	0	\N	2.00	\N	\N	\N	\N	draft	2025-11-24 21:17:12.617276	2025-11-25 03:56:52.066
\.


--
-- Data for Name: criteria_targets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.criteria_targets (id, criteria_id, unit_id, period_id, target_value, note, created_at, updated_at) FROM stdin;
e4dad8bd-8c6f-444b-baf3-525b216c9b4d	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:29:29.54	2025-11-24 08:29:29.54
57eb9290-659e-4bf2-a420-8b88e610c4dd	5620079f-e61f-4e50-8571-a5c2dd9de71e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	90.00	\N	2025-11-24 08:29:47.046	2025-11-24 08:29:47.046
63636d90-6f70-4aab-b624-730e8e39c890	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:30:16.387	2025-11-24 08:30:16.387
9ad475d6-9600-48a2-a2ad-5962ce7f3901	5620079f-e61f-4e50-8571-a5c2dd9de71e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	90.00	\N	2025-11-24 08:30:49.489	2025-11-24 08:30:49.489
14e8b84d-df9b-484e-a85c-3f2d18257934	309b57b1-e23c-41c0-9d69-175782810453	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	5.00	\N	2025-11-24 08:31:37.386	2025-11-24 08:31:37.386
36b29e6f-083d-4dfe-8283-7dbd9c9bcc88	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	75.00	\N	2025-11-24 08:31:54.01	2025-11-24 08:31:54.01
b01f7552-b2bc-4c1a-97d8-096426d8a0b9	309b57b1-e23c-41c0-9d69-175782810453	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	5.00	\N	2025-11-24 08:32:03.872	2025-11-24 08:32:03.872
79a19734-47d5-4c18-bc8d-54743b8d15b2	60087a36-e314-4fc1-b4d7-9aa1a33e4109	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:32:16.756	2025-11-24 08:32:16.756
04158063-eb7e-43f5-9d13-d472d84044a5	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	75.00	\N	2025-11-24 08:32:20.775	2025-11-24 08:32:20.775
803e79e5-1b92-4341-ad69-4b5f0c454d37	60087a36-e314-4fc1-b4d7-9aa1a33e4109	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	10.00	\N	2025-11-24 08:32:43.187	2025-11-24 08:32:43.187
b1d5f08d-e9fc-4284-a21b-b1ed930de6ee	600a025b-0c42-4f27-9475-0316676f584c	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:32:51.397	2025-11-24 08:32:51.397
e6cf5cac-8858-4a27-86fd-fc1f6b7b56c4	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:33:01.682	2025-11-24 08:33:01.682
e131a289-fe29-45d0-a8c6-8333f8f1d450	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:31:26.567	2025-11-24 08:33:22.722
5caf1d13-0034-48ef-8179-50cc54af59fd	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:33:40.15	2025-11-24 08:33:40.15
0e9e3a9e-395e-4223-94c9-dd15a18338b8	600a025b-0c42-4f27-9475-0316676f584c	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:33:43.929	2025-11-24 08:33:43.929
0c4ccde4-143d-4fb8-b0e2-c682293678db	4b68575e-b415-45b1-9338-b43937cb7a76	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:34:13.942	2025-11-24 08:34:13.942
fa72c4e3-0c06-40aa-afe2-bcf565d31201	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:34:16.482	2025-11-24 08:34:16.482
6afafae6-03b8-4ef5-893d-774af110b9a8	c684de0e-7f27-4e91-87a3-4f5ae46156bc	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:34:30.854	2025-11-24 08:34:30.854
bf28995f-9be0-4f06-bc37-0468c0cea606	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:34:57.736	2025-11-24 08:34:57.736
88697397-31fc-485c-b250-8078d3e6d43e	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:35:00.966	2025-11-24 08:35:00.966
d6b1a66b-0c5a-4236-9ce0-385a16901e2e	165aae17-5f5b-476e-bd69-05c16e9e4c24	a83099d1-517b-4f76-8b9a-62293b211b46	e638a53b-668c-49b8-8090-878c2969a1f1	8.00	\N	2025-11-24 08:35:10.735	2025-11-24 08:35:10.735
74b1f75f-ea4e-4bcb-a7de-bc0f3ba5aa6b	4b68575e-b415-45b1-9338-b43937cb7a76	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:35:30.972	2025-11-24 08:35:30.972
0a9a3899-b0cc-4866-aff4-4fa78979ceef	c684de0e-7f27-4e91-87a3-4f5ae46156bc	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:35:41.146	2025-11-24 08:35:41.146
00bca5bc-3455-4cfa-a516-d7c8a814d5dc	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:36:09.903	2025-11-24 08:36:09.903
ca4376e7-8352-464d-8291-ffac7da422a4	165aae17-5f5b-476e-bd69-05c16e9e4c24	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:36:22.867	2025-11-24 08:36:22.867
4893234f-7a60-431d-b7f0-a595024da48c	60087a36-e314-4fc1-b4d7-9aa1a33e4109	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:41:44.098	2025-11-24 08:41:44.098
8b434a08-f479-4046-8e46-548f25defb9c	5620079f-e61f-4e50-8571-a5c2dd9de71e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.90	\N	2025-11-24 08:44:56.589	2025-11-24 08:44:56.589
7a7550ba-9d04-4591-80a1-a0d660479439	600a025b-0c42-4f27-9475-0316676f584c	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:46:12.975	2025-11-24 08:46:12.975
5288c02d-60e1-4bfc-ba65-5c45c8fedadb	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:46:20.351	2025-11-24 08:46:20.351
f92e19e7-f5ae-420f-917a-f864c14c8e29	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:47:02.091	2025-11-24 08:47:02.091
af9510b5-e64a-4312-893c-927c58159270	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	60.00	\N	2025-11-24 08:47:40.655	2025-11-24 08:47:40.655
2908e392-b523-4910-a105-61a6d8ccc8eb	60087a36-e314-4fc1-b4d7-9aa1a33e4109	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:55:29.664	2025-11-24 08:55:29.664
e42862a9-7ed3-4516-9aa3-cec425bc967f	600a025b-0c42-4f27-9475-0316676f584c	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:56:02.381	2025-11-24 08:56:02.381
43b24e86-e830-414f-972a-b5a21ac44a38	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:56:25.383	2025-11-24 08:56:25.383
7e54223f-0d06-484e-948e-49119d787982	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:56:37.52	2025-11-24 08:56:37.52
d3ef8c78-d97e-43c8-94ff-c36d4bc2406d	4b68575e-b415-45b1-9338-b43937cb7a76	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:57:14.75	2025-11-24 08:57:14.75
8aa969de-f7f0-479f-876a-58d3c7c8defc	c684de0e-7f27-4e91-87a3-4f5ae46156bc	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 08:57:30.15	2025-11-24 08:57:30.15
0de3e168-d55d-4d3c-80b3-8bfb7b4d4997	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:58:08.439	2025-11-24 08:58:08.439
7ea214e6-fd0f-43dc-984a-00836015e510	165aae17-5f5b-476e-bd69-05c16e9e4c24	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 08:58:18.669	2025-11-24 08:58:18.669
d397eefa-04ef-482e-9150-434c3b5bcab2	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:09:16.89	2025-11-24 09:09:16.89
2ff9b9dd-482c-47e2-95d5-7d41829c823c	5620079f-e61f-4e50-8571-a5c2dd9de71e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	90.00	\N	2025-11-24 09:10:45.218	2025-11-24 09:10:58.957
be68946e-82a5-4297-b629-58f6e39c5f2e	5620079f-e61f-4e50-8571-a5c2dd9de71e	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	90.00	\N	2025-11-24 09:12:18.494	2025-11-24 09:13:32.099
987fb8e3-44a9-4817-afb9-8a4333c6fb46	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	75.00	\N	2025-11-24 09:15:12.035	2025-11-24 09:15:12.035
0ca50c2e-c13d-45d2-a04c-a328e8de9799	60087a36-e314-4fc1-b4d7-9aa1a33e4109	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:15:57.763	2025-11-24 09:15:57.763
3b0a59f8-4cb9-49c3-bbe1-a68be32b8e4d	600a025b-0c42-4f27-9475-0316676f584c	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 09:16:32.825	2025-11-24 09:16:32.825
a8808f98-0034-4cae-86b5-5a0931bd4b3e	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:16:56.092	2025-11-24 09:16:56.092
48b33de9-f60c-4cd1-a9ce-165ad54b3bb7	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	60.00	\N	2025-11-24 09:17:18.526	2025-11-24 09:17:18.526
6180dab1-cbc7-4ad9-b50a-b466b605c53e	4b68575e-b415-45b1-9338-b43937cb7a76	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:17:44.398	2025-11-24 09:17:44.398
a567e1f7-144a-4e97-b3b8-450f2a31ce3c	c684de0e-7f27-4e91-87a3-4f5ae46156bc	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:17:49.763	2025-11-24 09:17:49.763
e5c8c188-98ed-4614-9caa-0100be162df3	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:19:14.786	2025-11-24 09:19:14.786
9f485354-3673-45b3-ae55-e73775166e0a	165aae17-5f5b-476e-bd69-05c16e9e4c24	2f660f23-eb97-4b73-94d8-b86e7e3842e5	e638a53b-668c-49b8-8090-878c2969a1f1	2.00	\N	2025-11-24 09:19:30.33	2025-11-24 09:19:30.33
460d9cc3-8263-430d-aa89-ddddbf2672bc	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	75.00	\N	2025-11-24 09:25:57.198	2025-11-24 09:25:57.198
3b8d70fa-034b-45d4-8b53-72cb02f68145	4b68575e-b415-45b1-9338-b43937cb7a76	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:27:01.702	2025-11-24 09:27:12.014
2c44367d-e540-4317-a2ec-bf49ba055b56	c684de0e-7f27-4e91-87a3-4f5ae46156bc	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:27:17.531	2025-11-24 09:27:17.531
255ae2c8-ca0c-4ed2-b169-2ad0089df538	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 09:27:58.682	2025-11-24 09:27:58.682
ab7dc4b5-5dc8-4778-b3c4-9721e5731e2f	165aae17-5f5b-476e-bd69-05c16e9e4c24	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	2.00	\N	2025-11-24 09:28:19.93	2025-11-24 09:28:19.93
83c7b77f-9ee8-4dce-ad81-25f9d7e62c11	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.75	\N	2025-11-24 09:28:34.615	2025-11-24 09:28:41.344
d6af76b9-382c-4f83-add2-00c7a30b273e	309b57b1-e23c-41c0-9d69-175782810453	64fb7a1d-100b-4de9-a96e-fe834b49942e	e638a53b-668c-49b8-8090-878c2969a1f1	0.05	\N	2025-11-24 09:28:06.408	2025-11-24 09:28:46.773
55b7517f-5f12-4a7c-b8d5-3ad4436af52b	309b57b1-e23c-41c0-9d69-175782810453	0a87759e-5a6e-4ebb-9622-024a45bb38ae	e638a53b-668c-49b8-8090-878c2969a1f1	5.00	\N	2025-11-24 12:55:38.902	2025-11-24 12:55:38.902
c7a44735-057b-4de7-9de5-8f2b5fd76116	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 13:21:59.573	2025-11-24 13:21:59.573
98780370-1bf1-4d48-b44a-724819a51544	5620079f-e61f-4e50-8571-a5c2dd9de71e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	9.00	\N	2025-11-24 13:22:51.068	2025-11-24 14:27:56.885
d49023b7-0a15-46ac-ab1b-1f4806c1fb8c	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	3.00	\N	2025-11-24 13:27:18.611	2025-11-24 13:27:18.611
55868b7e-b998-4331-9b93-7781c1553194	c684de0e-7f27-4e91-87a3-4f5ae46156bc	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-24 13:32:31.118	2025-11-24 13:32:31.118
6cfa83c5-3ddd-434f-a605-9ae75ef997c1	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 13:33:55.597	2025-11-24 13:33:55.597
36afa41a-fe78-4f83-a355-326919de8299	309b57b1-e23c-41c0-9d69-175782810453	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 14:29:59.008	2025-11-24 14:29:59.008
b3e9ed49-c932-445b-9195-0504762099e7	600a025b-0c42-4f27-9475-0316676f584c	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 13:29:35.247	2025-11-24 14:08:47.402
b18cb0f2-794e-4f1a-8619-1e69f0a90d9a	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 13:30:38.461	2025-11-24 14:09:08.442
52f98ab9-cb69-4340-9405-cfe77a28dfd7	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 13:30:59.512	2025-11-24 14:09:14.428
116496b1-3d0d-4558-bc62-eb1a789fd4b2	4b68575e-b415-45b1-9338-b43937cb7a76	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 13:31:30.303	2025-11-24 14:09:36.264
0058b03c-a507-4eba-a39d-d9b317654cf6	165aae17-5f5b-476e-bd69-05c16e9e4c24	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 13:34:18.275	2025-11-24 14:10:31.915
03d88aa5-8636-4424-a431-fd5321806c5e	60087a36-e314-4fc1-b4d7-9aa1a33e4109	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-25 02:08:45.188	2025-11-25 02:08:45.188
9814c080-3884-406f-8ff5-9fb08d41c7c8	60087a36-e314-4fc1-b4d7-9aa1a33e4109	567d7f2e-1280-4265-8251-f0609b33058c	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-24 13:28:52.907	2025-11-24 14:33:51.781
9be3cbf0-d0a4-4ad0-b0a1-2041a63d6005	6d602ffb-4fc8-40bb-8e7a-98bf98419ba4	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-25 02:03:56.893	2025-11-25 02:03:56.893
140b8a46-217b-4b9a-a571-69ff10f123b2	600a025b-0c42-4f27-9475-0316676f584c	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-25 02:16:12.276	2025-11-25 02:16:12.276
33e028db-f3e9-4407-a5d5-856e362288bb	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-25 02:16:34.663	2025-11-25 02:16:34.663
bd06ef19-df1d-4dea-9507-fe4fd96d0981	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-25 02:17:15.994	2025-11-25 02:17:15.994
f2c127dd-2956-4b0c-989b-d3844158b709	4b68575e-b415-45b1-9338-b43937cb7a76	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-25 02:17:57.209	2025-11-25 02:17:57.209
921feb8d-5097-4406-b3e1-5611bde2f22b	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	75.00	\N	2025-11-25 02:07:54.943	2025-11-25 03:27:09.674
93468528-87c0-4021-879d-49705ba2e0bf	309b57b1-e23c-41c0-9d69-175782810453	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	5.00	\N	2025-11-25 02:06:38.95	2025-11-25 03:27:41.071
7004e278-3c76-4ce0-ba03-7c6f570c3618	c684de0e-7f27-4e91-87a3-4f5ae46156bc	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-25 02:18:05.007	2025-11-25 02:18:05.007
c69f2525-433d-4dab-8777-bcbe259f86f4	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	1.00	\N	2025-11-25 02:19:09.98	2025-11-25 02:19:09.98
5bd02745-fda3-43e3-a826-37553711d8da	165aae17-5f5b-476e-bd69-05c16e9e4c24	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-25 02:21:22.595	2025-11-25 02:21:22.595
5451c2a5-cba6-41f3-bf75-67a28990d933	5620079f-e61f-4e50-8571-a5c2dd9de71e	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	e638a53b-668c-49b8-8090-878c2969a1f1	0.00	\N	2025-11-25 02:02:40.794	2025-11-25 03:10:08.047
\.


--
-- Data for Name: evaluation_period_clusters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evaluation_period_clusters (id, period_id, cluster_id, created_at) FROM stdin;
c6d26f45-1dff-4585-b807-d1c6bae9312b	c78e19e7-abf0-4075-aa8a-5c0af714b764	99432257-142b-4c62-80cc-db9d02d09164	2025-11-23 09:56:22.313468
d78bc58c-3024-474d-bd06-dcdc2ee013cc	c78e19e7-abf0-4075-aa8a-5c0af714b764	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	2025-11-23 09:56:22.313468
6586dabc-9073-4c8a-a7c7-41bb386034e7	c78e19e7-abf0-4075-aa8a-5c0af714b764	e94c3da5-034a-46e5-873e-563045dbaea9	2025-11-23 09:56:22.313468
23e1d9c6-9de2-459a-8aa3-402dc0abfe1e	e638a53b-668c-49b8-8090-878c2969a1f1	99432257-142b-4c62-80cc-db9d02d09164	2025-11-23 15:57:24.387551
846eef0b-3821-4726-ade4-c3207585fa32	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	2025-11-23 15:57:24.387551
\.


--
-- Data for Name: evaluation_periods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evaluation_periods (id, name, year, start_date, end_date, status, created_at) FROM stdin;
c78e19e7-abf0-4075-aa8a-5c0af714b764	Kỳ thi đua 6 tháng đầu năm 2025	2025	2025-01-01 00:00:00	2025-06-30 00:00:00	active	2025-11-22 17:01:25.739457
e638a53b-668c-49b8-8090-878c2969a1f1	Nam 2025	2025	2025-01-15 00:00:00	2025-11-23 02:56:11.83	active	2025-11-23 09:57:05.808616
\.


--
-- Data for Name: evaluations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evaluations (id, period_id, cluster_id, unit_id, status, total_self_score, total_review1_score, total_review2_score, total_final_score, created_at, updated_at) FROM stdin;
5b62290f-a8ef-42d7-9a15-ebc9820e11bc	c78e19e7-abf0-4075-aa8a-5c0af714b764	99432257-142b-4c62-80cc-db9d02d09164	f1ee3d53-2eaf-4e3a-8bda-f3564ea3994a	draft	\N	\N	\N	\N	2025-11-23 09:55:18.375218	2025-11-23 09:55:18.375218
5918e54f-4173-4592-895a-dc59be31d9c5	c78e19e7-abf0-4075-aa8a-5c0af714b764	99432257-142b-4c62-80cc-db9d02d09164	293684dc-ca6c-4fc8-b212-fe0936000d46	draft	\N	\N	\N	\N	2025-11-23 09:55:18.377578	2025-11-23 09:55:18.377578
c22abfe8-4ed1-42d1-954d-74a6cb2cfc1c	c78e19e7-abf0-4075-aa8a-5c0af714b764	99432257-142b-4c62-80cc-db9d02d09164	d44a6de7-a466-479c-8d24-971671a943c9	draft	\N	\N	\N	\N	2025-11-23 09:55:18.379219	2025-11-23 09:55:18.379219
4e16529a-9985-40c3-93a1-107d202b04e2	c78e19e7-abf0-4075-aa8a-5c0af714b764	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	56c93f85-16f6-4f14-adf6-0838fd9fda17	draft	\N	\N	\N	\N	2025-11-23 09:55:18.381207	2025-11-23 09:55:18.381207
ba09883f-8dd5-4bc2-9460-7d74ae3c81df	c78e19e7-abf0-4075-aa8a-5c0af714b764	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	0c2e6bb4-cb4a-4db3-b9e9-0d4094e09f0a	draft	\N	\N	\N	\N	2025-11-23 09:55:18.382708	2025-11-23 09:55:18.382708
23c034d9-2358-4edb-9bf1-69dca8f5ebc2	c78e19e7-abf0-4075-aa8a-5c0af714b764	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	1fcc7ca2-7408-4da4-aaaa-6f50fd46912a	draft	\N	\N	\N	\N	2025-11-23 09:55:18.384296	2025-11-23 09:55:18.384296
2bf00786-ebd4-4988-ab17-785f333751f1	c78e19e7-abf0-4075-aa8a-5c0af714b764	e94c3da5-034a-46e5-873e-563045dbaea9	9ff8b7d4-d1fa-4363-92b4-475f0f0f5de3	draft	\N	\N	\N	\N	2025-11-23 09:55:18.386341	2025-11-23 09:55:18.386341
aa81def0-490a-4b26-839a-2ef04543268d	c78e19e7-abf0-4075-aa8a-5c0af714b764	e94c3da5-034a-46e5-873e-563045dbaea9	1561fa48-beab-4496-a7b5-a5364e77f055	draft	\N	\N	\N	\N	2025-11-23 09:55:18.387906	2025-11-23 09:55:18.387906
e77e9218-fc80-411e-8b8e-9df1d0495376	e638a53b-668c-49b8-8090-878c2969a1f1	99432257-142b-4c62-80cc-db9d02d09164	f1ee3d53-2eaf-4e3a-8bda-f3564ea3994a	draft	\N	\N	\N	\N	2025-11-23 09:57:14.412681	2025-11-23 09:57:14.412681
54990b4f-af42-4d82-8406-08d13a3669da	e638a53b-668c-49b8-8090-878c2969a1f1	99432257-142b-4c62-80cc-db9d02d09164	293684dc-ca6c-4fc8-b212-fe0936000d46	draft	\N	\N	\N	\N	2025-11-23 09:57:14.414165	2025-11-23 09:57:14.414165
ff4e7389-05c1-4c2d-a0fc-8aa7576b6650	e638a53b-668c-49b8-8090-878c2969a1f1	99432257-142b-4c62-80cc-db9d02d09164	d44a6de7-a466-479c-8d24-971671a943c9	draft	\N	\N	\N	\N	2025-11-23 09:57:14.415426	2025-11-23 09:57:14.415426
bb663470-380a-4227-88f9-a4084da0a7ee	e638a53b-668c-49b8-8090-878c2969a1f1	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	56c93f85-16f6-4f14-adf6-0838fd9fda17	draft	\N	\N	\N	\N	2025-11-23 09:57:14.417196	2025-11-23 09:57:14.417196
b1dbe7c2-f47d-46ab-8d86-daa23173347a	e638a53b-668c-49b8-8090-878c2969a1f1	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	0c2e6bb4-cb4a-4db3-b9e9-0d4094e09f0a	draft	\N	\N	\N	\N	2025-11-23 09:57:14.41853	2025-11-23 09:57:14.41853
80e09c6d-c1d3-4b49-b5a4-f12e1aae781c	e638a53b-668c-49b8-8090-878c2969a1f1	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	1fcc7ca2-7408-4da4-aaaa-6f50fd46912a	draft	\N	\N	\N	\N	2025-11-23 09:57:14.419963	2025-11-23 09:57:14.419963
e227d31d-f79e-41d4-b67f-e0ac49b32f47	e638a53b-668c-49b8-8090-878c2969a1f1	e94c3da5-034a-46e5-873e-563045dbaea9	9ff8b7d4-d1fa-4363-92b4-475f0f0f5de3	draft	\N	\N	\N	\N	2025-11-23 09:57:14.421677	2025-11-23 09:57:14.421677
3564053e-d65e-4d47-88fe-bafd45ec96b0	e638a53b-668c-49b8-8090-878c2969a1f1	e94c3da5-034a-46e5-873e-563045dbaea9	1561fa48-beab-4496-a7b5-a5364e77f055	draft	\N	\N	\N	\N	2025-11-23 09:57:14.422879	2025-11-23 09:57:14.422879
707872af-4eb1-4540-97f9-91c01f4f111d	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	submitted	\N	\N	\N	\N	2025-11-23 15:57:25.7914	2025-11-23 15:57:25.7914
186eb7de-dc3f-4561-bcc9-d32e66004b0f	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	a83099d1-517b-4f76-8b9a-62293b211b46	submitted	\N	\N	\N	\N	2025-11-23 15:48:07.642657	2025-11-23 15:48:07.642657
8e2dd1ef-bc22-4536-af14-801f1e5683c9	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	64fb7a1d-100b-4de9-a96e-fe834b49942e	submitted	\N	\N	\N	\N	2025-11-23 15:57:25.795359	2025-11-23 15:57:25.795359
da8000c2-06db-45e9-a2ab-701a88775b76	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	2f660f23-eb97-4b73-94d8-b86e7e3842e5	submitted	\N	\N	\N	\N	2025-11-23 15:57:25.796788	2025-11-23 15:57:25.796788
a0caf3e7-3c1f-41f3-96c9-ed0c6c2d845a	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	0a87759e-5a6e-4ebb-9622-024a45bb38ae	submitted	\N	\N	\N	\N	2025-11-23 15:57:25.79286	2025-11-23 15:57:25.79286
c3b6c443-9728-40be-a680-f301b904d7a6	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	submitted	\N	\N	\N	\N	2025-11-23 15:48:07.640809	2025-11-23 15:48:07.640809
b6814606-9e78-4bc0-b804-b58b15e0cd08	e638a53b-668c-49b8-8090-878c2969a1f1	80ef8ccc-fe70-4352-9e59-44735eeb3378	567d7f2e-1280-4265-8251-f0609b33058c	submitted	0.00	475.57	\N	475.57	2025-11-23 15:57:25.794058	2025-11-23 15:57:25.794058
\.


--
-- Data for Name: scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scores (id, evaluation_id, criteria_id, actual_value, count, bonus_count, penalty_count, is_achieved, calculated_score, self_score, self_score_file, self_score_date, review1_score, review1_comment, review1_file, review1_date, review1_by, explanation, explanation_file, explanation_date, review2_score, review2_comment, review2_file, review2_date, review2_by, final_score, created_at, updated_at) FROM stdin;
b5baec5e-2192-4d92-948c-86abeff3054d	b6814606-9e78-4bc0-b804-b58b15e0cd08	91f0d26e-c70a-4522-ba08-2a38cf823fd0	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:48:50.54	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:48:48.166697	2025-11-25 10:48:48.166697
200ad8c6-78c5-48b9-9d22-2a2b8423e0ea	b6814606-9e78-4bc0-b804-b58b15e0cd08	7313230c-811c-45e7-ba72-bc8ebcd65f7a	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:49:35.776	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:49:20.593901	2025-11-25 09:49:20.593901
2361f700-43a2-47b3-a664-4c19bcdfc527	b6814606-9e78-4bc0-b804-b58b15e0cd08	10392de9-00c3-4461-8c03-8b9df80b9dd1	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:48:44.022	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:48:41.518126	2025-11-25 10:48:41.518126
91071292-4d97-44b5-afaa-2cb4d8709908	b6814606-9e78-4bc0-b804-b58b15e0cd08	f144dbc6-4ae1-4075-b9f5-66bf15ba3a1f	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không hoàn thành chỉ tiêu. Chỉ tiêu có giao.	\N	2025-11-25 03:14:50.364	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:14:30.015677	2025-11-25 10:14:30.015677
adaa9299-156c-4f55-aa03-15623c97ddf7	b6814606-9e78-4bc0-b804-b58b15e0cd08	165aae17-5f5b-476e-bd69-05c16e9e4c24	\N	\N	0	0	\N	\N	\N	\N	\N	0.00		\N	2025-11-25 03:17:36.762	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:17:31.988961	2025-11-25 10:17:31.988961
73474967-339f-4d1c-a51a-7ee1311f9cfd	b6814606-9e78-4bc0-b804-b58b15e0cd08	7f535beb-fb86-4761-9ed6-6a3b32fc2ffa	\N	\N	0	0	\N	\N	\N	\N	\N	0.00		\N	2025-11-25 03:17:23.684	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:17:18.687792	2025-11-25 10:17:18.687792
369d7511-02d4-4291-8e65-2ca64b109597	b6814606-9e78-4bc0-b804-b58b15e0cd08	4b68575e-b415-45b1-9338-b43937cb7a76	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Giao chỉ tiêu nhưng chưa hoàn thành	\N	2025-11-25 03:16:25.982	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:16:01.033008	2025-11-25 10:16:01.033008
ccbb0189-4f41-45cc-8dc5-3a3be45b3172	b6814606-9e78-4bc0-b804-b58b15e0cd08	e14f39a3-c101-44d1-9bfa-66b6b7ce4829	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:51:31.541	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:51:26.244266	2025-11-25 09:51:26.244266
42787f26-3ac2-4c2c-827d-c82fc1556787	b6814606-9e78-4bc0-b804-b58b15e0cd08	5d3f47f8-725f-46d5-9d63-3c0e66c009d2	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:50:16.892	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:50:08.488375	2025-11-25 09:50:08.488375
638b0da6-0f23-4d2b-879c-75cbc3ba5d37	b6814606-9e78-4bc0-b804-b58b15e0cd08	8a2d8de0-bc45-4be5-8cf5-a4b3c35c235e	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không giao chỉ tiêu, không có vụviệc	\N	2025-11-25 03:15:35.224	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:15:07.995703	2025-11-25 10:15:07.995703
f2c7d5c4-7ca6-4585-9c1b-959ef0da2409	b6814606-9e78-4bc0-b804-b58b15e0cd08	cc239035-3c1b-41b2-a71a-2a43f5728543	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:49:11.165	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:49:01.951722	2025-11-25 09:49:01.951722
17288c75-a83f-4875-8ada-5bdf82223a27	b6814606-9e78-4bc0-b804-b58b15e0cd08	309b57b1-e23c-41c0-9d69-175782810453	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không hoàn thành chỉ tiêu	\N	2025-11-25 03:12:16.609	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:07:23.929164	2025-11-25 10:07:23.929164
a1de4f18-6595-4cf4-8aed-b7151f5280db	b6814606-9e78-4bc0-b804-b58b15e0cd08	da26b8bc-3aa4-4c7e-b005-c2a79d369cba	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:07:02.768	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:06:51.306221	2025-11-25 10:06:51.306221
31694cb8-faa0-4187-9147-ba1b045388ef	b6814606-9e78-4bc0-b804-b58b15e0cd08	87605a36-1a09-42c9-8362-ee3f79925b46	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:54:57.94	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:54:41.640872	2025-11-25 09:54:41.640872
9530554c-7765-428a-be85-22e2899459b4	b6814606-9e78-4bc0-b804-b58b15e0cd08	600a025b-0c42-4f27-9475-0316676f584c	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không giao, không phát hiện	\N	2025-11-25 03:14:02.074	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:13:38.237691	2025-11-25 10:13:38.237691
4089c1a1-9f8e-4257-b93e-2a082c737c23	b6814606-9e78-4bc0-b804-b58b15e0cd08	60087a36-e314-4fc1-b4d7-9aa1a33e4109	\N	\N	0	0	\N	\N	\N	\N	\N	5.00	Hoàn thành chỉ tiêu định lượng, được 1/2 số điểm	\N	2025-11-25 03:11:58.087	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:11:15.975105	2025-11-25 10:11:15.975105
e351c35c-4d6d-4dc0-9bf8-fe08525e7bcc	b6814606-9e78-4bc0-b804-b58b15e0cd08	4ee5ebe7-18d1-4f58-9437-1c89ab884ad6	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 02:51:42.602	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 09:51:38.376446	2025-11-25 09:51:38.376446
3a071e03-e9b8-41b7-a732-173aeca93de9	b6814606-9e78-4bc0-b804-b58b15e0cd08	8c181441-36a7-432a-a2de-2026909f9a41	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:50:20.601	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:50:12.874126	2025-11-25 09:50:12.874126
a80ce0dc-0c91-4107-ab97-d9553f6d65b8	b6814606-9e78-4bc0-b804-b58b15e0cd08	bb2e4d2d-e679-4c62-a88e-ce92baaf2368	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:51:04.019	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:50:56.432467	2025-11-25 09:50:56.432467
41c38d9c-c50a-488e-a71d-303167ae9583	b6814606-9e78-4bc0-b804-b58b15e0cd08	d32ec9db-b64f-42c7-a21e-16a443599cf5	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:49:40.418	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:49:28.565524	2025-11-25 09:49:28.565524
066ede29-0e4d-40ce-a021-9c55ac72ae7d	b6814606-9e78-4bc0-b804-b58b15e0cd08	18aaf397-5d9c-42f9-a327-fa0fba8d477d	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:34:55.318	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:34:52.166623	2025-11-25 10:34:52.166623
46ee98b5-4123-4683-a291-a64fe913f53a	b6814606-9e78-4bc0-b804-b58b15e0cd08	f05a6cc8-a921-4f10-99f5-0b5afda37328	\N	\N	0	0	\N	\N	\N	\N	\N	0.00		\N	2025-11-25 03:34:42.946	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:34:39.426872	2025-11-25 10:34:39.426872
861642bf-a3de-4999-81cf-4ba113d9c5f1	b6814606-9e78-4bc0-b804-b58b15e0cd08	db9717f5-c7a7-4532-97b1-e33f0ec86750	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:29:14.3	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:29:11.375833	2025-11-25 10:29:11.375833
6cf8a8ef-b0f7-4585-a76b-b080d7bba4a2	b6814606-9e78-4bc0-b804-b58b15e0cd08	285c236b-e5a0-4f89-89ca-6f9b140fd0ab	\N	\N	0	0	\N	\N	\N	\N	\N	3.00		\N	2025-11-25 03:34:34.396	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2025-11-25 10:34:14.814693	2025-11-25 10:34:14.814693
e193385e-8a2d-40d3-9e51-51788dedaf21	b6814606-9e78-4bc0-b804-b58b15e0cd08	eb7bd701-5795-43cc-8391-21426990fbb5	\N	\N	0	0	\N	\N	\N	\N	\N	3.82	kết quả từ pc06	\N	2025-11-25 03:21:42.76	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.82	2025-11-25 10:21:22.192277	2025-11-25 10:21:22.192277
4fb4a8d4-9793-46f4-87a0-5650e00cf0ce	b6814606-9e78-4bc0-b804-b58b15e0cd08	bdf2e59f-8c98-4df8-bc36-dc4573a0606b	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không giao	\N	2025-11-25 03:25:29.328	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:25:20.869892	2025-11-25 10:25:20.869892
13815b18-a9de-47af-9298-e203a9b507d6	b6814606-9e78-4bc0-b804-b58b15e0cd08	d9337788-d07b-487e-a8ea-79bd9a237706	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:22:16.456	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:22:10.346087	2025-11-25 10:22:10.346087
6cf6a0ad-1235-4a45-a274-5a0e9d42cc9b	b6814606-9e78-4bc0-b804-b58b15e0cd08	31466b47-7a2c-48d7-a4aa-cde19dfabc5f	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	xảy ra 2 vụ cháy cấp 2	\N	2025-11-25 03:31:27.603	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:31:11.767423	2025-11-25 10:31:11.767423
66c2ff5f-20a0-4e53-a546-00738580018c	b6814606-9e78-4bc0-b804-b58b15e0cd08	23db48b5-e04d-4351-b095-bdf2defff0c4	\N	\N	0	0	\N	\N	\N	\N	\N	8.00		\N	2025-11-25 03:34:27.071	\N	\N	\N	\N	\N	\N	\N	\N	\N	8.00	2025-11-25 10:34:03.927821	2025-11-25 10:34:03.927821
ed7d8711-1ff0-44c3-82ce-16b4f85de8b1	b6814606-9e78-4bc0-b804-b58b15e0cd08	be878744-4347-47da-9a82-7a1dde8a1077	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 03:19:21.552	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 10:19:16.570342	2025-11-25 10:19:16.570342
9d55b24c-f903-4e9d-9151-8e6b420e58bb	b6814606-9e78-4bc0-b804-b58b15e0cd08	141ea20f-cf29-48a2-b367-6ac07a5bd7b4	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không giao chỉ tiêu	\N	2025-11-25 03:24:23.102	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:23:43.568977	2025-11-25 10:23:43.568977
46188489-2cd0-43e5-80ce-d784150ee945	b6814606-9e78-4bc0-b804-b58b15e0cd08	db10be95-c13b-4487-b8d2-d03a5e784e69	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:29:07.804	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:29:04.844638	2025-11-25 10:29:04.844638
d3e99a9f-adba-4d71-8f60-52c5bf962972	b6814606-9e78-4bc0-b804-b58b15e0cd08	ef8f8ad5-2255-4292-a371-a681701526bc	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 02:49:53.91	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 09:49:47.285459	2025-11-25 09:49:47.285459
0329ada9-8fe2-4600-8111-6febaa78401a	b6814606-9e78-4bc0-b804-b58b15e0cd08	26857eb0-eb02-4639-a4fd-b38ed6a6ca30	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:24:44.609	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:24:40.485663	2025-11-25 10:24:40.485663
dc073b79-c0f8-4475-9fc8-8e92459d8488	b6814606-9e78-4bc0-b804-b58b15e0cd08	1f752b6d-e8ff-4061-97f6-310f6fa0664b	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 03:33:29.944	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 10:33:25.414144	2025-11-25 10:33:25.414144
9106cea2-703a-4ad1-81a1-e635f2003d2d	b6814606-9e78-4bc0-b804-b58b15e0cd08	d1635049-c122-4492-9597-7e125fcf09f8	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:25:06.147	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:25:02.751711	2025-11-25 10:25:02.751711
7b8bf44d-a1ec-4589-9865-aa171d33ecf0	b6814606-9e78-4bc0-b804-b58b15e0cd08	20b83a28-4fe7-4d6c-a242-f5f8462c6e14	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:27:57.657	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:27:48.405724	2025-11-25 10:27:48.405724
3c27e9bb-d709-46ef-ad2c-ea5925fe00de	b6814606-9e78-4bc0-b804-b58b15e0cd08	750d4861-d84c-4622-a0f5-e709289e603b	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:32:40.683	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:31:47.151777	2025-11-25 10:31:47.151777
21d54a9d-3f65-4a2f-81e3-ee5bf052aabc	b6814606-9e78-4bc0-b804-b58b15e0cd08	d555ced7-1211-4d31-8c05-cc44b14c20a1	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:36:43.698	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:36:41.176947	2025-11-25 10:36:41.176947
2f949855-cc36-4398-ad48-f0b1c4bfe025	b6814606-9e78-4bc0-b804-b58b15e0cd08	97ee726a-f9c6-4c65-9794-543a6feb7a1b	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 03:33:14.778	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 10:33:11.178869	2025-11-25 10:33:11.178869
a00ca2bf-3b61-4f71-888d-53539713ae4c	b6814606-9e78-4bc0-b804-b58b15e0cd08	47e1c021-cef6-4889-baa9-d824d461da1d	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Công an xã Sen Ngư chưa xây dựng mới được hiềm nghi nào	\N	2025-11-25 03:42:11.382	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:41:40.860043	2025-11-25 10:41:40.860043
20fd12a9-53d2-487e-bf32-e5cb27f163ac	b6814606-9e78-4bc0-b804-b58b15e0cd08	246965b3-e65a-48f9-9f68-fdda80be8169	\N	\N	0	0	\N	\N	\N	\N	\N	4.00		\N	2025-11-25 03:28:50.929	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.00	2025-11-25 10:28:38.916075	2025-11-25 10:28:38.916075
2bb572a7-3a28-42b4-aa65-a781330765d5	b6814606-9e78-4bc0-b804-b58b15e0cd08	726d7760-d6d8-4b9c-bc15-c751fd612610	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 03:39:13.385	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 10:39:10.125077	2025-11-25 10:39:10.125077
97a124ef-add6-451a-addd-50fbbaf1fe6b	b6814606-9e78-4bc0-b804-b58b15e0cd08	2161ca82-71b5-419f-bd3d-4a38216dca25	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	CAX Sen Ngư có 14 CSBM nhưng chưa có HTBM, chưa hoàn thành chỉ tiêu	\N	2025-11-25 03:43:25.035	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:42:54.08352	2025-11-25 10:42:54.08352
865b9a5c-ebd2-47ac-844b-017fc7476baa	b6814606-9e78-4bc0-b804-b58b15e0cd08	b87ffbd0-0798-4c0c-8dd4-c91450b5bad5	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:48:58.18	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:48:55.690722	2025-11-25 10:48:55.690722
1f526911-d945-458b-9687-2a33522f7ee8	b6814606-9e78-4bc0-b804-b58b15e0cd08	5546bd4e-c045-4d52-8cd6-79408f8af1a3	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 03:45:25.546	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 10:45:18.339233	2025-11-25 10:45:18.339233
419a3979-cf99-46d2-b888-9fd38682202b	b6814606-9e78-4bc0-b804-b58b15e0cd08	cfc7afc5-ef90-44e0-a9e8-7bd12e6dac24	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:45:10.568	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:45:04.111141	2025-11-25 10:45:04.111141
646bd1eb-4cb7-47bf-8ea7-5bbb8f72afaf	b6814606-9e78-4bc0-b804-b58b15e0cd08	485d3228-8245-454e-bc68-f2ce6c944263	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:35:56.616	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:35:53.000465	2025-11-25 10:35:53.000465
385cc77e-f2ce-4b2b-bc18-7df9ba1d8671	b6814606-9e78-4bc0-b804-b58b15e0cd08	dc47d96f-a72d-417b-a156-fc743e5e2f1a	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 03:44:33.126	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 10:44:28.196254	2025-11-25 10:44:28.196254
158bdd50-330d-4236-8db2-ec4db6bdb684	b6814606-9e78-4bc0-b804-b58b15e0cd08	d142142b-d819-4303-bdff-8d2c3a10e327	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Công an xã Sen Ngư chưa xây dựng mới được hiềm nghi nào	\N	2025-11-25 03:42:27.433	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:42:22.461023	2025-11-25 10:42:22.461023
25100856-d4b3-4072-b2bd-eec7b76198d0	b6814606-9e78-4bc0-b804-b58b15e0cd08	87dd917d-e936-49b5-8457-1a0b2ee49565	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không lập mới sưu tra loại B	\N	2025-11-25 03:40:05.646	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:39:46.318895	2025-11-25 10:39:46.318895
e2ac78e9-e63a-4b56-964b-01706160ea4a	b6814606-9e78-4bc0-b804-b58b15e0cd08	5380bbd9-3b86-40ce-8597-2c87077ff5f8	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:38:50.47	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:38:47.046877	2025-11-25 10:38:47.046877
eea6ee23-b4dc-417a-bd36-a005b6e975fc	b6814606-9e78-4bc0-b804-b58b15e0cd08	381a96ff-c413-4412-8b19-3c0117aea3ec	\N	\N	0	0	\N	\N	\N	\N	\N	20.00		\N	2025-11-25 02:48:50.17	\N	\N	\N	\N	\N	\N	\N	\N	\N	20.00	2025-11-25 09:48:32.87796	2025-11-25 09:48:32.87796
5c39c454-398f-42c5-8647-312c37dd3a0e	b6814606-9e78-4bc0-b804-b58b15e0cd08	73f03686-ee9a-4579-b3bc-3303e354e180	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:37:18.648	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:37:15.348345	2025-11-25 10:37:15.348345
91c6e581-253c-4442-9b7a-34b0ba08a974	b6814606-9e78-4bc0-b804-b58b15e0cd08	c490447c-6617-40d5-99a1-11e57139290a	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Đơn vị không có cá nhân tham gia đoàn Công an tỉnh tham gia hội thi, hội diễn nghệ thuật quần chúng	\N	2025-11-25 03:50:49.787	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:50:18.573201	2025-11-25 10:50:18.573201
bb63a165-fc1b-4220-ae34-0a5e20954927	b6814606-9e78-4bc0-b804-b58b15e0cd08	2c25c3bd-19b0-4aab-a99e-806e527815fe	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:49:15.517	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:49:13.369834	2025-11-25 10:49:13.369834
d795cb9b-46d7-45d9-afac-17a1b287b549	b6814606-9e78-4bc0-b804-b58b15e0cd08	eb34c054-6d3c-4fef-a5ed-a13d36ce0b28	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:37:09.09	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:37:05.347546	2025-11-25 10:37:05.347546
1dfb0e5e-262a-48d9-8b71-bfb03789a088	b6814606-9e78-4bc0-b804-b58b15e0cd08	0d874a0f-1b7a-4004-8cda-1952c40f5928	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:48:08.295	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:48:05.779345	2025-11-25 10:48:05.779345
b542a88e-5a97-4cb5-ad5a-f58affe64b34	b6814606-9e78-4bc0-b804-b58b15e0cd08	432950d8-25a9-4726-b24f-6869f9c12c10	\N	\N	0	0	\N	\N	\N	\N	\N	4.00		\N	2025-11-25 03:47:37.306	\N	\N	\N	\N	\N	\N	\N	\N	\N	4.00	2025-11-25 10:47:33.932157	2025-11-25 10:47:33.932157
124262b7-6d1c-4844-a31e-1558a4077ef5	b6814606-9e78-4bc0-b804-b58b15e0cd08	3af0b0f0-c9e8-4823-a1a0-c6e3c91f5615	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:47:50.982	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:47:48.254537	2025-11-25 10:47:48.254537
da683014-cb26-4c61-87dc-2b853682a84e	b6814606-9e78-4bc0-b804-b58b15e0cd08	30ce5a37-830c-4e6f-9ab5-d108b2d856aa	\N	\N	0	0	\N	\N	\N	\N	\N	3.00		\N	2025-11-25 03:48:02.058	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2025-11-25 10:47:58.934122	2025-11-25 10:47:58.934122
6f9a2857-a016-4a1d-8f4b-5523bb79b29c	b6814606-9e78-4bc0-b804-b58b15e0cd08	04d20169-ff00-42ad-b2a2-81f9adf94c2f	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:48:30.572	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:48:27.898571	2025-11-25 10:48:27.898571
40b5d46c-95e2-4cc7-a19a-ebbafe677f62	b6814606-9e78-4bc0-b804-b58b15e0cd08	d78d6c6a-abf8-42de-9062-cd4d80ff6f5b	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:38:58.73	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:38:55.892888	2025-11-25 10:38:55.892888
6bb97c9d-7de4-4807-a33c-b0509316e952	b6814606-9e78-4bc0-b804-b58b15e0cd08	ad29789d-b8ad-4f31-a8ba-0df790b6d48e	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 03:42:46.789	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 10:42:43.066989	2025-11-25 10:42:43.066989
06618c1b-dc19-41a7-ab08-49b27ce0d991	b6814606-9e78-4bc0-b804-b58b15e0cd08	319be6c1-eb00-41bc-8f80-48dd12d3d3dd	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:46:06.741	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:46:03.598815	2025-11-25 10:46:03.598815
a61a178e-0f4a-4a3c-9086-09187f96f24f	b6814606-9e78-4bc0-b804-b58b15e0cd08	3462ddf3-f516-4363-87f8-44d2ba92da64	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:46:59.194	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:46:55.751664	2025-11-25 10:46:55.751664
c8edd64c-7aa5-4f35-8395-56f83baefe57	b6814606-9e78-4bc0-b804-b58b15e0cd08	53dc5a74-fab1-4942-a54f-21a5f34b45ae	\N	\N	0	0	\N	\N	\N	\N	\N	1.50		\N	2025-11-25 03:46:23.976	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	2025-11-25 10:46:19.781847	2025-11-25 10:46:19.781847
52b340b1-22c1-4fba-bab6-35ecfc493ae4	b6814606-9e78-4bc0-b804-b58b15e0cd08	94b798d5-13b9-49ad-9d22-228a3f07bfb5	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:36:04.781	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:36:01.720883	2025-11-25 10:36:01.720883
80f7a1a3-6f93-4b9b-bbbf-6b9b5aaf422b	b6814606-9e78-4bc0-b804-b58b15e0cd08	c6d93be0-f50d-49a8-9a45-4b6a7383f9cb	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:36:51.085	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:36:48.715767	2025-11-25 10:36:48.715767
5ad16165-4640-43fd-81c1-dede5618f698	b6814606-9e78-4bc0-b804-b58b15e0cd08	712bccaa-5cb6-4eb1-be8e-304d5c700e3d	\N	\N	0	0	\N	\N	\N	\N	\N	15.00		\N	2025-11-25 03:44:14.842	\N	\N	\N	\N	\N	\N	\N	\N	\N	15.00	2025-11-25 10:44:08.95944	2025-11-25 10:44:08.95944
2752ebfe-9d31-4bfc-a4d9-276425198f65	b6814606-9e78-4bc0-b804-b58b15e0cd08	a5719761-6a08-41c6-99be-e1b631c41975	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:45:34.548	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:45:31.610294	2025-11-25 10:45:31.610294
adc49be4-001f-4251-af3c-25744dcff070	b6814606-9e78-4bc0-b804-b58b15e0cd08	e823904a-7a2c-474e-895b-ba225efc6751	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:45:57.719	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:45:49.731882	2025-11-25 10:45:49.731882
a79c4e98-0548-4660-a7f5-4c86206ec4e4	b6814606-9e78-4bc0-b804-b58b15e0cd08	0dc41e0d-ef7f-43e7-b467-1678112877f9	\N	\N	0	0	\N	\N	\N	\N	\N	1.50		\N	2025-11-25 03:46:38.356	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	2025-11-25 10:46:33.178846	2025-11-25 10:46:33.178846
5e3a834c-56c3-41f5-bfaa-41cb82901a99	b6814606-9e78-4bc0-b804-b58b15e0cd08	3e76bba7-f386-4124-ba55-3eea01d1a38f	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:58:14.402	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:58:10.888015	2025-11-25 10:58:10.888015
0461fb32-c92d-4eab-902c-8bdfcfc9f181	b6814606-9e78-4bc0-b804-b58b15e0cd08	b487f5d9-5e12-478d-8798-f6203a871885	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:57:17.888	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:57:15.158133	2025-11-25 10:57:15.158133
594854c7-d1ac-4355-9c59-b472f314a72f	b6814606-9e78-4bc0-b804-b58b15e0cd08	936d4b77-3c36-4008-97fe-7742a432e046	\N	\N	0	0	\N	\N	\N	\N	\N	8.00	Đề xuất, kiến nghị được cấp trên tiếp thu: Không có	\N	2025-11-25 03:55:42.6	\N	\N	\N	\N	\N	\N	\N	\N	\N	8.00	2025-11-25 10:55:33.243248	2025-11-25 10:55:33.243248
b6d6c95c-72e7-45a2-9e4c-9a269d294708	b6814606-9e78-4bc0-b804-b58b15e0cd08	07132dd0-4bd5-4601-8a9b-6d05b87d354c	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:58:01.675	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:57:59.316527	2025-11-25 10:57:59.316527
186c5344-17f7-44b0-9b9c-d090d519e639	b6814606-9e78-4bc0-b804-b58b15e0cd08	7244fa14-e0a5-4366-a31a-e136039445ba	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:47:10.563	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:47:07.101836	2025-11-25 10:47:07.101836
fe3a9fe3-0345-4811-a2bc-8349562edc44	b6814606-9e78-4bc0-b804-b58b15e0cd08	c6a60793-756f-4526-8f3f-ed2f9b7703a4	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:57:53.738	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:57:51.488354	2025-11-25 10:57:51.488354
0e923580-6f1d-4960-9d8d-a710ad53ed0f	b6814606-9e78-4bc0-b804-b58b15e0cd08	88e5c0e3-6caf-4066-8851-e201c76e2ec1	\N	\N	0	0	\N	\N	\N	\N	\N	0.75		\N	2025-11-25 03:51:16.205	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.75	2025-11-25 10:51:11.054302	2025-11-25 10:51:11.054302
68830920-a676-4e1c-84c4-b471cdd119f1	b6814606-9e78-4bc0-b804-b58b15e0cd08	24703ccc-61d6-4e27-9325-8dd505493afb	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không có hội phụ nữ, không giao chỉ tiêu, không chấm điểm	\N	2025-11-25 03:52:29.069	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:52:20.790254	2025-11-25 10:52:20.790254
fedc0362-3c68-4ca5-b96a-7af8a6b193da	b6814606-9e78-4bc0-b804-b58b15e0cd08	4baf6310-700f-4a03-84e6-24d2efa70d69	\N	\N	0	0	\N	\N	\N	\N	\N	8.00	Đề xuất, kiến nghị được cấp trên tiếp thu: Không có	\N	2025-11-25 03:54:21.583	\N	\N	\N	\N	\N	\N	\N	\N	\N	8.00	2025-11-25 10:54:15.072888	2025-11-25 10:54:15.072888
69ffc8d7-4c5f-4186-ba75-99f366f08a5e	b6814606-9e78-4bc0-b804-b58b15e0cd08	473fb095-1711-489f-8b16-6ff5aac4f1d5	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 03:53:04.334	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 10:53:00.881732	2025-11-25 10:53:00.881732
07d34954-3272-4a64-93e7-afc1a962c270	b6814606-9e78-4bc0-b804-b58b15e0cd08	d38a02ec-2612-466e-9e40-dcbf8ec952bb	\N	\N	0	0	\N	\N	\N	\N	\N	8.00	Đề xuất, kiến nghị được cấp trên tiếp thu: Không có	\N	2025-11-25 03:55:17.425	\N	\N	\N	\N	\N	\N	\N	\N	\N	8.00	2025-11-25 10:55:08.89692	2025-11-25 10:55:08.89692
a90d8b00-1ead-4ef2-a020-39e16a450e99	b6814606-9e78-4bc0-b804-b58b15e0cd08	b5e500c7-e88c-4922-84ba-8baec799d1b3	\N	\N	0	0	\N	\N	\N	\N	\N	8.00	Đề xuất, kiến nghị được cấp trên tiếp thu: Không có	\N	2025-11-25 03:54:44.464	\N	\N	\N	\N	\N	\N	\N	\N	\N	8.00	2025-11-25 10:54:39.867497	2025-11-25 10:54:39.867497
6b158744-c277-4642-9196-d4d90ffa5a40	b6814606-9e78-4bc0-b804-b58b15e0cd08	a805f62c-4fbe-4d0d-8ddb-ea951a49ff06	\N	\N	0	0	\N	\N	\N	\N	\N	0.00		\N	2025-11-25 03:51:26.425	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 10:51:23.28872	2025-11-25 10:51:23.28872
9242dfa4-41f5-4dd3-8ed1-09076342c489	b6814606-9e78-4bc0-b804-b58b15e0cd08	2e8a7134-2e2f-4b69-8bb8-3394cea840f5	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:48:22.369	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:48:16.283784	2025-11-25 10:48:16.283784
7f921d10-f467-432e-8925-6b14bb6f99c4	b6814606-9e78-4bc0-b804-b58b15e0cd08	1418079e-67b7-465c-9ac3-b626ea3dfdbf	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:57:28.965	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:57:26.24509	2025-11-25 10:57:26.24509
35928031-e2cb-439c-b439-0655c9a40bbe	b6814606-9e78-4bc0-b804-b58b15e0cd08	03f57b1f-7375-4f4d-bef7-4ad4ea04beac	\N	\N	0	0	\N	\N	\N	\N	\N	8.00	Đề xuất, kiến nghị được cấp trên tiếp thu: Không có	\N	2025-11-25 03:53:48.742	\N	\N	\N	\N	\N	\N	\N	\N	\N	8.00	2025-11-25 10:53:22.042582	2025-11-25 10:53:22.042582
73c07321-6f56-4acd-bcf9-f6d1d152a436	b6814606-9e78-4bc0-b804-b58b15e0cd08	04fddf93-0005-43c2-bd35-ca2b965fe44b	\N	\N	0	0	\N	\N	\N	\N	\N	3.00		\N	2025-11-25 03:56:27.744	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2025-11-25 10:56:22.019294	2025-11-25 10:56:22.019294
476c79a3-4024-4bac-9089-e85db29d96be	b6814606-9e78-4bc0-b804-b58b15e0cd08	90dc2f36-7803-4077-9ffa-c33881dba242	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:57:44.706	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:57:41.953157	2025-11-25 10:57:41.953157
53fcf0a5-2340-4d83-a3d5-5d13dd952428	b6814606-9e78-4bc0-b804-b58b15e0cd08	992ee7ea-da8f-42cc-8a1c-5caa06b3dd8a	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Đơn vị không tham gia nghiên cứu đề tài khoa học nào	\N	2025-11-25 04:02:59.397	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 11:02:53.137152	2025-11-25 11:02:53.137152
e1d1373b-5918-43ca-8758-9b3737889392	b6814606-9e78-4bc0-b804-b58b15e0cd08	12a78dac-7c82-4032-b61d-53b858b29b9d	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 04:00:40.799	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:00:38.222995	2025-11-25 11:00:38.222995
9e0a1b17-4239-490e-9ce4-f048ef3ba0fd	b6814606-9e78-4bc0-b804-b58b15e0cd08	95ecadd0-d137-4bfc-b69b-12cf556a467c	\N	\N	0	0	\N	\N	\N	\N	\N	8.00		\N	2025-11-25 04:02:22.676	\N	\N	\N	\N	\N	\N	\N	\N	\N	8.00	2025-11-25 11:02:20.073649	2025-11-25 11:02:20.073649
03105e0e-f101-424b-a1cf-5df7c5aca632	b6814606-9e78-4bc0-b804-b58b15e0cd08	b5927146-8aaf-4409-8142-3f4c11c4f2b4	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 04:00:46.854	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:00:44.580894	2025-11-25 11:00:44.580894
1d6a4edd-6cc0-4d11-961a-a20dbf240801	b6814606-9e78-4bc0-b804-b58b15e0cd08	7d9015f4-f8d0-4fe7-87a9-faf55a48b413	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:56:52.061	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:56:49.271509	2025-11-25 10:56:49.271509
8765a98b-161e-4c04-98f9-21807bc47ab8	b6814606-9e78-4bc0-b804-b58b15e0cd08	06d115ef-b738-4f1d-9a9c-9e8a0150def5	\N	\N	0	0	\N	\N	\N	\N	\N	10.00		\N	2025-11-25 04:02:11.003	\N	\N	\N	\N	\N	\N	\N	\N	\N	10.00	2025-11-25 11:02:06.977577	2025-11-25 11:02:06.977577
267c8693-46c0-4df9-9862-75578820de38	b6814606-9e78-4bc0-b804-b58b15e0cd08	140368b6-7511-4d5c-a434-4fb50da9f877	\N	\N	0	0	\N	\N	\N	\N	\N	3.00		\N	2025-11-25 04:01:25.379	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2025-11-25 11:01:22.694469	2025-11-25 11:01:22.694469
6e81a675-1b82-4857-84b6-4cff766beabc	b6814606-9e78-4bc0-b804-b58b15e0cd08	c79e3144-f71f-49ed-92fb-421e459bf2af	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:59:39.127	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:59:36.111744	2025-11-25 10:59:36.111744
e78f4939-9886-4921-8ea0-f8bad87a59de	b6814606-9e78-4bc0-b804-b58b15e0cd08	8f47dc3a-b639-4d09-acb9-4dbb9bde9859	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 04:01:46.764	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:01:43.154919	2025-11-25 11:01:43.154919
f5b39733-dbe3-4535-b488-97f140f8192d	b6814606-9e78-4bc0-b804-b58b15e0cd08	1463af4f-223f-4146-ae23-9a326a61ad7e	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:59:47.349	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:59:44.571961	2025-11-25 10:59:44.571961
150229ff-71f3-411b-a687-a5dc5fa475cf	b6814606-9e78-4bc0-b804-b58b15e0cd08	04ebee63-5624-4a9f-9a69-7b519ddc2bef	\N	\N	0	0	\N	\N	\N	\N	\N	3.00		\N	2025-11-25 04:00:01.552	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2025-11-25 10:59:59.253543	2025-11-25 10:59:59.253543
627bf276-7524-4dd5-951f-7bb76c9e5280	b6814606-9e78-4bc0-b804-b58b15e0cd08	a6d07339-22c4-4da0-ab27-c3097e68cf5f	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 04:01:07.84	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:01:05.701591	2025-11-25 11:01:05.701591
4870323e-fd0a-43c4-b255-ec6b6062d279	b6814606-9e78-4bc0-b804-b58b15e0cd08	e5b3a64f-c4fe-4a5b-b561-ca8ae17eaa08	\N	\N	0	0	\N	\N	\N	\N	\N	3.00		\N	2025-11-25 04:01:32.778	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2025-11-25 11:01:30.234879	2025-11-25 11:01:30.234879
312a05b7-d18f-48ec-8843-4c5ab02ab8f0	b6814606-9e78-4bc0-b804-b58b15e0cd08	a423d0d4-c0dc-4c2c-ae5f-3d65ab05d34e	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 04:01:14.231	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:01:12.127928	2025-11-25 11:01:12.127928
72903e00-a181-47c2-9870-44f53a15d63d	b6814606-9e78-4bc0-b804-b58b15e0cd08	bcada071-a37b-4192-8c42-afdc522c3bf3	\N	\N	0	0	\N	\N	\N	\N	\N	1.00		\N	2025-11-25 03:58:24.899	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.00	2025-11-25 10:58:22.079108	2025-11-25 10:58:22.079108
61b7b7d3-4f22-4bcc-ac55-47daffb955b1	b6814606-9e78-4bc0-b804-b58b15e0cd08	78a0dcd2-f87c-4f9a-a8d1-8f77eaeed23f	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 04:00:53.703	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:00:51.024179	2025-11-25 11:00:51.024179
42fec1e8-a066-4652-97a5-28f4b0dcc125	b6814606-9e78-4bc0-b804-b58b15e0cd08	0797b27a-f581-418c-a1fd-4c85a8442591	\N	\N	0	0	\N	\N	\N	\N	\N	1.50		\N	2025-11-25 04:00:29.264	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	2025-11-25 11:00:23.912008	2025-11-25 11:00:23.912008
78ab356b-ebc1-4ea6-ae91-72520614cad1	b6814606-9e78-4bc0-b804-b58b15e0cd08	fdd1bdf8-b346-4dfa-b5e0-7a4280edb254	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 04:01:54.34	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:01:51.365193	2025-11-25 11:01:51.365193
00277b44-1a24-41c0-82be-ec2c2e8764c2	b6814606-9e78-4bc0-b804-b58b15e0cd08	f7ae6ec6-ad8f-44b7-b90e-80f7268786eb	\N	\N	0	0	\N	\N	\N	\N	\N	1.50		\N	2025-11-25 04:00:16.136	\N	\N	\N	\N	\N	\N	\N	\N	\N	1.50	2025-11-25 11:00:08.284736	2025-11-25 11:00:08.284736
ebd81baf-5dd5-4bb8-bcc5-d0a37ec43088	b6814606-9e78-4bc0-b804-b58b15e0cd08	036c63d8-d0b1-412c-ac70-40bf5d359877	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:59:05.802	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:59:02.138439	2025-11-25 10:59:02.138439
18dc4f2e-6955-48e1-b663-6caa08cf74fc	b6814606-9e78-4bc0-b804-b58b15e0cd08	620d7dc8-dd2d-437b-9cc7-c96fbf4002e4	\N	\N	0	0	\N	\N	\N	\N	\N	0.00		\N	2025-11-25 04:09:07.692	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 11:09:04.942951	2025-11-25 11:09:04.942951
c253ee03-81c6-4263-abd4-07fbbf0e904a	b6814606-9e78-4bc0-b804-b58b15e0cd08	46c164ab-fe99-4e6f-bb2c-0ec9b62d1da4	\N	\N	0	0	\N	\N	\N	\N	\N	3.00		\N	2025-11-25 04:08:26.118	\N	\N	\N	\N	\N	\N	\N	\N	\N	3.00	2025-11-25 11:08:22.445139	2025-11-25 11:08:22.445139
4d577730-2da1-4dc2-8141-796dd596a73b	b6814606-9e78-4bc0-b804-b58b15e0cd08	ef232bc9-a97d-46cf-b838-ea67e96b5271	\N	\N	0	0	\N	\N	\N	\N	\N	0.00	Không có	\N	2025-11-25 04:08:45.116	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 11:07:49.283863	2025-11-25 11:07:49.283863
cf4115f2-b5a6-4789-a684-7a36e2f5ab97	b6814606-9e78-4bc0-b804-b58b15e0cd08	bfbc3091-9661-482e-aa9b-4a9e4409cb6a	\N	\N	0	0	\N	\N	\N	\N	\N	2.00		\N	2025-11-25 03:58:32.46	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 10:58:29.674889	2025-11-25 10:58:29.674889
5582cf7b-d8ea-4118-b81b-4656db386b70	b6814606-9e78-4bc0-b804-b58b15e0cd08	d016962d-b0c4-4e42-942f-9cad60ba440f	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 04:03:24.502	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 11:03:21.200725	2025-11-25 11:03:21.200725
e6140b7c-8cdb-43cf-b0f1-d2f3f52859a1	b6814606-9e78-4bc0-b804-b58b15e0cd08	dbfe7009-2130-49be-a36d-f80b4cc0dfe4	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 04:03:33.082	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 11:03:30.776883	2025-11-25 11:03:30.776883
4fba45a9-461c-40e6-a96b-ba382ff63b8d	b6814606-9e78-4bc0-b804-b58b15e0cd08	bcfac4d1-207b-4978-b551-1719db9d7ae8	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 04:03:40.324	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 11:03:37.23821	2025-11-25 11:03:37.23821
b63bc406-b9ff-435a-90fd-96f970216cbd	b6814606-9e78-4bc0-b804-b58b15e0cd08	68a08d0e-6535-4e43-adeb-fa90fa585e59	\N	\N	0	0	\N	\N	\N	\N	\N	0.00		\N	2025-11-25 04:09:15.581	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 11:09:12.187903	2025-11-25 11:09:12.187903
135ca6cb-912c-441c-8ac3-7214768a4fbc	b6814606-9e78-4bc0-b804-b58b15e0cd08	20d84ee4-ac0a-4365-ad68-83359862ae69	\N	\N	0	0	\N	\N	\N	\N	\N	0.00		\N	2025-11-25 04:03:59.902	\N	\N	\N	\N	\N	\N	\N	\N	\N	0.00	2025-11-25 11:03:56.987097	2025-11-25 11:03:56.987097
cdf3120f-0ba0-4c83-8cce-194f025d2819	b6814606-9e78-4bc0-b804-b58b15e0cd08	d9d26ff4-1341-4c25-82e1-8ec562b829f9	\N	\N	0	0	\N	\N	\N	\N	\N	5.00		\N	2025-11-25 04:04:08.906	\N	\N	\N	\N	\N	\N	\N	\N	\N	5.00	2025-11-25 11:04:06.783134	2025-11-25 11:04:06.783134
e32b4755-4a50-4cba-8f25-f1ddc158ce58	b6814606-9e78-4bc0-b804-b58b15e0cd08	f8a1368d-2826-45ab-84a2-6e25a76a3a74	\N	\N	0	0	\N	\N	\N	\N	\N	2.00	Trước sáp nhập,  tập thể Công an xã Sen Thủy cũ có 01 lượt Bằng khen của Bộ Công an về công tác tuyển quyân (Quyết định số 5569/QĐ-BCA ngày 30/6/2025)	\N	2025-11-25 04:06:51.436	\N	\N	\N	\N	\N	\N	\N	\N	\N	2.00	2025-11-25 11:05:42.984328	2025-11-25 11:05:42.984328
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (sid, sess, expire) FROM stdin;
VKpOxCIQsQCKikvbAmtt_ivIQczTHT-m	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-01T08:22:42.523Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"2c6193bf-0ba7-450a-866b-7591b64c6c8d"}}	2025-12-01 16:06:31
3UbCzot2DStpum10ObRXFoR0Vcoqxx7Q	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-01T08:51:43.081Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"292f1eaf-a86a-4fb1-ab83-36de7cce2107"}}	2025-12-02 07:23:14
MkdIwVdDCb4vsPhLXqhVDxQBXW3XAfNx	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-02T01:33:30.562Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"8a789345-e68f-412d-9ccd-185b46f690f3"}}	2025-12-02 10:32:18
k6UJE87vTtRb5ydGUm_mIAl4WVxMfWH2	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-01T08:33:41.485Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"6cd068ca-5521-4077-9f34-694c542bfc66"}}	2025-12-01 17:08:24
dkthoASzrzId-ojD-mMhhu6Au3KzFRtu	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-02T00:58:11.403Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"443c90f8-38f2-4262-aec5-606a8c974a0c"}}	2025-12-02 11:09:16
b_UDVwUhPA2qUMzlbqdN5kD-LnlzMA62	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-01T13:08:53.008Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"6131758d-fb9e-4eb4-98e2-102695af61ca"}}	2025-12-02 09:45:32
IJjLtm_gbtmqpSZRXWwlJczJE7DDnjdV	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-01T08:22:09.068Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"ed382ccf-7e3c-4051-82c5-a3fd6c5c5dd5"}}	2025-12-01 20:34:53
nuyu-v4jsyK5cWSFCnA_lB7OrfW7EPh9	{"cookie":{"originalMaxAge":604800000,"expires":"2025-12-01T01:34:10.111Z","secure":false,"httpOnly":true,"path":"/","sameSite":"lax"},"passport":{"user":"a5efb5b2-8da2-4ee9-a073-6750e3646135"}}	2025-12-02 11:52:29
\.


--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.units (id, name, short_name, cluster_id, description, created_at, updated_at) FROM stdin;
f1ee3d53-2eaf-4e3a-8bda-f3564ea3994a	Phòng Cảnh sát Hình sự	PC02	99432257-142b-4c62-80cc-db9d02d09164	Phòng Cảnh sát Hình sự Công an TP.HCM	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
293684dc-ca6c-4fc8-b212-fe0936000d46	Phòng Cảnh sát Giao thông	PC08	99432257-142b-4c62-80cc-db9d02d09164	Phòng Cảnh sát Giao thông Công an TP.HCM	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
d44a6de7-a466-479c-8d24-971671a943c9	Phòng An ninh Chính trị nội bộ	PA03	99432257-142b-4c62-80cc-db9d02d09164	Phòng An ninh Chính trị nội bộ Công an TP.HCM	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
56c93f85-16f6-4f14-adf6-0838fd9fda17	Công an Phường Bến Nghé	CAPBN	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	Công an Phường Bến Nghé, Quận 1	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
0c2e6bb4-cb4a-4db3-b9e9-0d4094e09f0a	Công an Phường Bến Thành	CAPBT	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	Công an Phường Bến Thành, Quận 1	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
1fcc7ca2-7408-4da4-aaaa-6f50fd46912a	Công an Phường Cô Giang	CAPCG	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	Công an Phường Cô Giang, Quận 1	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
9ff8b7d4-d1fa-4363-92b4-475f0f0f5de3	Công an Phường Võ Thị Sáu	CAPVTS	e94c3da5-034a-46e5-873e-563045dbaea9	Công an Phường Võ Thị Sáu, Quận 3	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
1561fa48-beab-4496-a7b5-a5364e77f055	Công an Phường 09	CAP09Q3	e94c3da5-034a-46e5-873e-563045dbaea9	Công an Phường 09, Quận 3	2025-11-22 17:01:25.253448	2025-11-22 17:01:25.253448
51fe6de8-23b2-4914-b6fa-5fab9c4cd182	Công an xã Cam Hồng	CAX _CH	80ef8ccc-fe70-4352-9e59-44735eeb3378	cam hồng	2025-11-23 15:34:23.094399	2025-11-23 15:34:23.094399
a83099d1-517b-4f76-8b9a-62293b211b46	Công an xã Lệ Thuỷ	CAX_LT	80ef8ccc-fe70-4352-9e59-44735eeb3378		2025-11-23 15:34:48.690346	2025-11-23 15:34:48.690346
89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	Công an xã Tân Mỹ	CAX_TM	80ef8ccc-fe70-4352-9e59-44735eeb3378	sdfs	2025-11-23 15:50:32.668135	2025-11-23 15:50:32.668135
0a87759e-5a6e-4ebb-9622-024a45bb38ae	Công an xã Trường Phú	CAX_TP	80ef8ccc-fe70-4352-9e59-44735eeb3378	sdf	2025-11-23 15:50:56.631241	2025-11-23 15:50:56.631241
567d7f2e-1280-4265-8251-f0609b33058c	Công an xã Sen Ngữ	CAX_SN	80ef8ccc-fe70-4352-9e59-44735eeb3378		2025-11-23 15:51:31.962346	2025-11-23 15:51:31.962346
64fb7a1d-100b-4de9-a96e-fe834b49942e	Công an xã Kim Ngân	CAX_KN	80ef8ccc-fe70-4352-9e59-44735eeb3378	dsf	2025-11-23 15:51:53.009399	2025-11-23 15:51:53.009399
2f660f23-eb97-4b73-94d8-b86e7e3842e5	Công an xã Vĩnh Linh	CAX_VL	80ef8ccc-fe70-4352-9e59-44735eeb3378		2025-11-23 15:52:31.714273	2025-11-23 15:52:31.714273
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, full_name, role, cluster_id, unit_id, created_at) FROM stdin;
830be888-a81b-411c-bdec-dfeaa830c824	admin	$2b$10$vqjr.Z7FxKeAy7xZicE.6e7sWnBIRIHgdcLSMgIvBA7NZjdXiNVc.	Quản trị viên hệ thống	admin	\N	\N	2025-11-22 17:01:25.735188
876130e1-42b1-47d3-8d4e-e44486df1a5d	cumtruong1	$2b$10$fAaRDTfMOeqMk.8sGkeLyuSbJ9ar5UMbQely0zrtw6xwIQ8n2HQW2	Cụm trưởng Cụm TP	cluster_leader	99432257-142b-4c62-80cc-db9d02d09164	\N	2025-11-22 17:01:25.735188
02a84c5c-d4b0-4f24-ad32-a1f2532bb418	cumtruong2	$2b$10$x3fPrfkeyYwo1HZYqI1lWuPcyRn/MOrkewIBJoh8xETJrCCjcNXPK	Cụm trưởng Cụm Xã phường Q1	cluster_leader	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	\N	2025-11-22 17:01:25.735188
a89b2f25-2894-4dea-ad90-88fcf0c261ef	cumtruong3	$2b$10$SxyFyamJujM6bDB8CVz0hOhteT5QoYhFlTOdOd30TmH.sJ5cmYI56	Cụm trưởng Cụm Xã phường Q3	cluster_leader	e94c3da5-034a-46e5-873e-563045dbaea9	\N	2025-11-22 17:01:25.735188
57055256-7d80-4590-a67e-10d6ad60ad67	donvi1	$2b$10$AxYzsy6Dxt5rrAr2FyFmo.Pv7MK9RA8gIPso0ZrJtffaxWX5GPVsW	Cán bộ PC02	user	99432257-142b-4c62-80cc-db9d02d09164	f1ee3d53-2eaf-4e3a-8bda-f3564ea3994a	2025-11-22 17:01:25.735188
f9987d76-e509-40ab-b789-e2407b16d2b3	donvi2	$2b$10$aZbttnRLVu9UpzXQtJZJ0eOq3iJpxd9ARwT2SDEbBBEFT7.0vvGVq	Cán bộ PC08	user	99432257-142b-4c62-80cc-db9d02d09164	293684dc-ca6c-4fc8-b212-fe0936000d46	2025-11-22 17:01:25.735188
fa4502f9-b809-4727-8c1d-44fa38f31f7d	donvi3	$2b$10$AR9zcGCdNtmYbdhbg6EJOeRLKjFpua0Tmu7QcIxtkjnR2s3wvb4O.	Cán bộ Phường Bến Nghé	user	799ffdd8-29b4-4d31-b899-5c02a7ea65bd	56c93f85-16f6-4f14-adf6-0838fd9fda17	2025-11-22 17:01:25.735188
443c90f8-38f2-4262-aec5-606a8c974a0c	cumtruong347	$2b$10$6lyjat.N5hoSosi6m.PcT.OuLabKGIomeRlkZLC.0ZBb/cTsD6GFy	Cụm thi đua số 347	cluster_leader	80ef8ccc-fe70-4352-9e59-44735eeb3378	\N	2025-11-23 15:35:39.358993
8a789345-e68f-412d-9ccd-185b46f690f3	cax_camhong	$2b$10$Hiw9hCEXlm8RJYsZTJZnGeV55zjBl.EO7qN0Vi4Nw7ZFg9cfWM.ma	Công an xã Cam Hồng	user	80ef8ccc-fe70-4352-9e59-44735eeb3378	51fe6de8-23b2-4914-b6fa-5fab9c4cd182	2025-11-23 15:53:28.737546
a5efb5b2-8da2-4ee9-a073-6750e3646135	cax_lethuy	$2b$10$MI2QmDD9EO0/jDh.n2V3COvsf5UwEYD3V53soaYiXlSSp52g652AC	Công an xã Lệ Thuỷ	user	80ef8ccc-fe70-4352-9e59-44735eeb3378	a83099d1-517b-4f76-8b9a-62293b211b46	2025-11-23 15:54:14.197351
2c6193bf-0ba7-450a-866b-7591b64c6c8d	cax_tanmy	$2b$10$4s4mgyKskdOiDbE9DqNrf.aZK1v3T1SWjjaBy6g.zXe6FiK5aV0ky	Công an xã Tân Mỹ	user	80ef8ccc-fe70-4352-9e59-44735eeb3378	89ef8a31-fcf4-4c2a-9e73-af94bd24c7ff	2025-11-23 15:54:47.627158
ed382ccf-7e3c-4051-82c5-a3fd6c5c5dd5	cax_truongphu	$2b$10$HdmA9AeJchYKP7nnmsLbheJskFmDgXoq9ylngbDorc8Ln53stFE0S	Công an xã Trường Phú	user	80ef8ccc-fe70-4352-9e59-44735eeb3378	0a87759e-5a6e-4ebb-9622-024a45bb38ae	2025-11-23 15:55:18.760743
6131758d-fb9e-4eb4-98e2-102695af61ca	cax_senngu	$2b$10$/mM1U77cIB1kox6sS2ZIGOXpPKGJalmKFsdsCyfwzOTOaxz5v2hzm	Công an xã Sen Ngữ	user	80ef8ccc-fe70-4352-9e59-44735eeb3378	567d7f2e-1280-4265-8251-f0609b33058c	2025-11-23 15:55:44.395181
6cd068ca-5521-4077-9f34-694c542bfc66	cax_kimngan	$2b$10$gXIHwxW0PDVaIpFEV4mlJ.VZGuFtk3bpQ15qB.0eGxpraWB5y43Uu	Công an xã Kim Ngân	user	80ef8ccc-fe70-4352-9e59-44735eeb3378	64fb7a1d-100b-4de9-a96e-fe834b49942e	2025-11-23 15:56:09.465544
292f1eaf-a86a-4fb1-ab83-36de7cce2107	cax_vinhlinh	$2b$10$W5jq3j2fRNR5I.2zTlsvBuvknEYYAQ/vf1/uD4n0jzXVlmzcoxa86	Công an xã Vĩnh Linh	user	80ef8ccc-fe70-4352-9e59-44735eeb3378	2f660f23-eb97-4b73-94d8-b86e7e3842e5	2025-11-23 15:56:55.550857
\.


--
-- Name: clusters clusters_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clusters
    ADD CONSTRAINT clusters_name_unique UNIQUE (name);


--
-- Name: clusters clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);


--
-- Name: clusters clusters_short_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clusters
    ADD CONSTRAINT clusters_short_name_unique UNIQUE (short_name);


--
-- Name: criteria_bonus_penalty criteria_bonus_penalty_criteria_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_bonus_penalty
    ADD CONSTRAINT criteria_bonus_penalty_criteria_id_unique UNIQUE (criteria_id);


--
-- Name: criteria_bonus_penalty criteria_bonus_penalty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_bonus_penalty
    ADD CONSTRAINT criteria_bonus_penalty_pkey PRIMARY KEY (id);


--
-- Name: criteria_fixed_score criteria_fixed_score_criteria_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_fixed_score
    ADD CONSTRAINT criteria_fixed_score_criteria_id_unique UNIQUE (criteria_id);


--
-- Name: criteria_fixed_score criteria_fixed_score_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_fixed_score
    ADD CONSTRAINT criteria_fixed_score_pkey PRIMARY KEY (id);


--
-- Name: criteria_formula criteria_formula_criteria_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_formula
    ADD CONSTRAINT criteria_formula_criteria_id_unique UNIQUE (criteria_id);


--
-- Name: criteria_formula criteria_formula_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_formula
    ADD CONSTRAINT criteria_formula_pkey PRIMARY KEY (id);


--
-- Name: criteria criteria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_pkey PRIMARY KEY (id);


--
-- Name: criteria_results criteria_results_criteria_id_unit_id_period_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_results
    ADD CONSTRAINT criteria_results_criteria_id_unit_id_period_id_unique UNIQUE (criteria_id, unit_id, period_id);


--
-- Name: criteria_results criteria_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_results
    ADD CONSTRAINT criteria_results_pkey PRIMARY KEY (id);


--
-- Name: criteria_targets criteria_targets_criteria_id_unit_id_period_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_targets
    ADD CONSTRAINT criteria_targets_criteria_id_unit_id_period_id_unique UNIQUE (criteria_id, unit_id, period_id);


--
-- Name: criteria_targets criteria_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_targets
    ADD CONSTRAINT criteria_targets_pkey PRIMARY KEY (id);


--
-- Name: evaluation_period_clusters evaluation_period_clusters_period_id_cluster_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_period_clusters
    ADD CONSTRAINT evaluation_period_clusters_period_id_cluster_id_unique UNIQUE (period_id, cluster_id);


--
-- Name: evaluation_period_clusters evaluation_period_clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_period_clusters
    ADD CONSTRAINT evaluation_period_clusters_pkey PRIMARY KEY (id);


--
-- Name: evaluation_periods evaluation_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_periods
    ADD CONSTRAINT evaluation_periods_pkey PRIMARY KEY (id);


--
-- Name: evaluations evaluations_period_id_unit_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_period_id_unit_id_unique UNIQUE (period_id, unit_id);


--
-- Name: evaluations evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_pkey PRIMARY KEY (id);


--
-- Name: scores scores_evaluation_id_criteria_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_evaluation_id_criteria_id_unique UNIQUE (evaluation_id, criteria_id);


--
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: units units_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_name_unique UNIQUE (name);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: units units_short_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_short_name_unique UNIQUE (short_name);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_unique UNIQUE (username);


--
-- Name: IDX_session_expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_session_expire" ON public.session USING btree (expire);


--
-- Name: criteria_period_cluster_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX criteria_period_cluster_idx ON public.criteria USING btree (period_id, cluster_id, parent_id, order_index);


--
-- Name: criteria_bonus_penalty criteria_bonus_penalty_criteria_id_criteria_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_bonus_penalty
    ADD CONSTRAINT criteria_bonus_penalty_criteria_id_criteria_id_fk FOREIGN KEY (criteria_id) REFERENCES public.criteria(id) ON DELETE CASCADE;


--
-- Name: criteria criteria_cluster_id_clusters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_cluster_id_clusters_id_fk FOREIGN KEY (cluster_id) REFERENCES public.clusters(id) ON DELETE CASCADE;


--
-- Name: criteria_fixed_score criteria_fixed_score_criteria_id_criteria_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_fixed_score
    ADD CONSTRAINT criteria_fixed_score_criteria_id_criteria_id_fk FOREIGN KEY (criteria_id) REFERENCES public.criteria(id) ON DELETE CASCADE;


--
-- Name: criteria_formula criteria_formula_criteria_id_criteria_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_formula
    ADD CONSTRAINT criteria_formula_criteria_id_criteria_id_fk FOREIGN KEY (criteria_id) REFERENCES public.criteria(id) ON DELETE CASCADE;


--
-- Name: criteria criteria_parent_id_criteria_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_parent_id_criteria_id_fk FOREIGN KEY (parent_id) REFERENCES public.criteria(id) ON DELETE CASCADE;


--
-- Name: criteria criteria_period_id_evaluation_periods_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_period_id_evaluation_periods_id_fk FOREIGN KEY (period_id) REFERENCES public.evaluation_periods(id) ON DELETE CASCADE;


--
-- Name: criteria_results criteria_results_criteria_id_criteria_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_results
    ADD CONSTRAINT criteria_results_criteria_id_criteria_id_fk FOREIGN KEY (criteria_id) REFERENCES public.criteria(id) ON DELETE CASCADE;


--
-- Name: criteria_results criteria_results_period_id_evaluation_periods_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_results
    ADD CONSTRAINT criteria_results_period_id_evaluation_periods_id_fk FOREIGN KEY (period_id) REFERENCES public.evaluation_periods(id) ON DELETE CASCADE;


--
-- Name: criteria_results criteria_results_unit_id_units_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_results
    ADD CONSTRAINT criteria_results_unit_id_units_id_fk FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE CASCADE;


--
-- Name: criteria_targets criteria_targets_criteria_id_criteria_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_targets
    ADD CONSTRAINT criteria_targets_criteria_id_criteria_id_fk FOREIGN KEY (criteria_id) REFERENCES public.criteria(id) ON DELETE CASCADE;


--
-- Name: criteria_targets criteria_targets_period_id_evaluation_periods_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_targets
    ADD CONSTRAINT criteria_targets_period_id_evaluation_periods_id_fk FOREIGN KEY (period_id) REFERENCES public.evaluation_periods(id) ON DELETE CASCADE;


--
-- Name: criteria_targets criteria_targets_unit_id_units_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteria_targets
    ADD CONSTRAINT criteria_targets_unit_id_units_id_fk FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE CASCADE;


--
-- Name: evaluation_period_clusters evaluation_period_clusters_cluster_id_clusters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_period_clusters
    ADD CONSTRAINT evaluation_period_clusters_cluster_id_clusters_id_fk FOREIGN KEY (cluster_id) REFERENCES public.clusters(id) ON DELETE CASCADE;


--
-- Name: evaluation_period_clusters evaluation_period_clusters_period_id_evaluation_periods_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_period_clusters
    ADD CONSTRAINT evaluation_period_clusters_period_id_evaluation_periods_id_fk FOREIGN KEY (period_id) REFERENCES public.evaluation_periods(id) ON DELETE CASCADE;


--
-- Name: evaluations evaluations_cluster_id_clusters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_cluster_id_clusters_id_fk FOREIGN KEY (cluster_id) REFERENCES public.clusters(id) ON DELETE CASCADE;


--
-- Name: evaluations evaluations_period_id_evaluation_periods_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_period_id_evaluation_periods_id_fk FOREIGN KEY (period_id) REFERENCES public.evaluation_periods(id) ON DELETE CASCADE;


--
-- Name: evaluations evaluations_unit_id_units_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_unit_id_units_id_fk FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE CASCADE;


--
-- Name: scores scores_criteria_id_criteria_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_criteria_id_criteria_id_fk FOREIGN KEY (criteria_id) REFERENCES public.criteria(id) ON DELETE CASCADE;


--
-- Name: scores scores_evaluation_id_evaluations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_evaluation_id_evaluations_id_fk FOREIGN KEY (evaluation_id) REFERENCES public.evaluations(id) ON DELETE CASCADE;


--
-- Name: scores scores_review1_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_review1_by_users_id_fk FOREIGN KEY (review1_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: scores scores_review2_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_review2_by_users_id_fk FOREIGN KEY (review2_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: units units_cluster_id_clusters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_cluster_id_clusters_id_fk FOREIGN KEY (cluster_id) REFERENCES public.clusters(id) ON DELETE RESTRICT;


--
-- Name: users users_cluster_id_clusters_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_cluster_id_clusters_id_fk FOREIGN KEY (cluster_id) REFERENCES public.clusters(id) ON DELETE SET NULL;


--
-- Name: users users_unit_id_units_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_unit_id_units_id_fk FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict goXCA6UuexK0pYiTvnbw56H9QBjlRyLi3h18v9WOf697Tr4cCw4FNzX49MBL6Y4

