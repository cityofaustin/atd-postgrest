--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.8 (Homebrew)

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

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA api;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: trigger_set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: knack; Type: TABLE; Schema: api; Owner: -
--

CREATE TABLE api.knack (
    record_id text NOT NULL,
    app_id text NOT NULL,
    container_id text NOT NULL,
    record json NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL
);


--
-- Name: knack_id_seq; Type: SEQUENCE; Schema: api; Owner: -
--

CREATE SEQUENCE api.knack_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knack_id_seq; Type: SEQUENCE OWNED BY; Schema: api; Owner: -
--

ALTER SEQUENCE api.knack_id_seq OWNED BY api.knack.id;


--
-- Name: knack_metadata; Type: TABLE; Schema: api; Owner: -
--

CREATE TABLE api.knack_metadata (
    app_id text NOT NULL,
    metadata jsonb NOT NULL
);


--
-- Name: knack id; Type: DEFAULT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.knack ALTER COLUMN id SET DEFAULT nextval('api.knack_id_seq'::regclass);


--
-- Name: knack_metadata knack_metadata_pkey; Type: CONSTRAINT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.knack_metadata
    ADD CONSTRAINT knack_metadata_pkey PRIMARY KEY (app_id);


--
-- Name: knack knack_pkey; Type: CONSTRAINT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.knack
    ADD CONSTRAINT knack_pkey PRIMARY KEY (record_id, app_id, container_id);


--
-- Name: id_unique_index; Type: INDEX; Schema: api; Owner: -
--

CREATE UNIQUE INDEX id_unique_index ON api.knack USING btree (id);


--
-- Name: knack_app_id_idx; Type: INDEX; Schema: api; Owner: -
--

CREATE INDEX knack_app_id_idx ON api.knack USING btree (app_id);


--
-- Name: knack_container_id_idx; Type: INDEX; Schema: api; Owner: -
--

CREATE INDEX knack_container_id_idx ON api.knack USING btree (container_id);


--
-- Name: updated_at_index; Type: INDEX; Schema: api; Owner: -
--

CREATE INDEX updated_at_index ON api.knack USING btree (updated_at);


--
-- Name: knack set_updated_at; Type: TRIGGER; Schema: api; Owner: -
--

CREATE TRIGGER set_updated_at BEFORE INSERT OR UPDATE ON api.knack FOR EACH ROW EXECUTE FUNCTION public.trigger_set_updated_at();


--
-- PostgreSQL database dump complete
--


--
-- custom api_user role definition
--
CREATE ROLE api_user NOLOGIN;

GRANT USAGE ON SCHEMA api TO api_user;

GRANT SELECT ON ALL TABLES IN SCHEMA api TO api_user;

GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA api TO api_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA api 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO api_user;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA api TO api_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA api
GRANT USAGE ON SEQUENCES TO api_user;
