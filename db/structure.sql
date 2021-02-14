SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: street_cafes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.street_cafes (
    id bigint NOT NULL,
    name character varying,
    address character varying,
    post_code character varying,
    num_chairs integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying
);


--
-- Name: cafe_category_info; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cafe_category_info AS
 SELECT street_cafes.category,
    count(*) AS total_places,
    sum(street_cafes.num_chairs) AS total_chairs
   FROM public.street_cafes
  GROUP BY street_cafes.category;


--
-- Name: post_code_info; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.post_code_info AS
 SELECT a.post_code,
    count(a.post_code) AS total_count,
    sum(a.num_chairs) AS total_chairs,
    concat(round((((sum(a.num_chairs))::numeric * 100.0) / (( SELECT sum(street_cafes.num_chairs) AS sum
           FROM public.street_cafes))::numeric), 2), '%') AS chairs_pct,
    max((b.name)::text) AS place_with_max_chairs,
    max(a.num_chairs) AS max_chairs
   FROM (public.street_cafes a
     LEFT JOIN ( SELECT street_cafes.name,
            street_cafes.post_code,
            street_cafes.num_chairs
           FROM public.street_cafes
          WHERE (((street_cafes.post_code)::text, street_cafes.num_chairs) IN ( SELECT street_cafes_1.post_code,
                    max(street_cafes_1.num_chairs) AS max
                   FROM public.street_cafes street_cafes_1
                  GROUP BY street_cafes_1.post_code))) b ON (((a.post_code)::text = (b.post_code)::text)))
  GROUP BY a.post_code;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: street_cafes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.street_cafes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: street_cafes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.street_cafes_id_seq OWNED BY public.street_cafes.id;


--
-- Name: street_cafes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.street_cafes ALTER COLUMN id SET DEFAULT nextval('public.street_cafes_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: street_cafes street_cafes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.street_cafes
    ADD CONSTRAINT street_cafes_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20210213161821'),
('20210213165037'),
('20210213165602'),
('20210214161846');


