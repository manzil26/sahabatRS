This folder contains SQL migrations for the project.

001_add_chat_fields_and_rls.sql

- Adds new columns to `public.chat`: `type`, `attachment_url`, `delivered_at`, `read_at`.
- Adds FK constraints (sender_id/receiver_id) referencing `auth.users(id)`.
- Creates useful indexes and enables RLS with policies to restrict access to conversation participants.

Note: If you encounter an error referencing `polname` when checking `pg_policies`, use the fixed file `001_add_chat_fields_and_rls_FIXED.sql` which checks `policyname` instead (some DB versions expose `policyname`).

How to run:

- Use Supabase SQL Editor or psql against your database and run the fixed SQL (`001_add_chat_fields_and_rls_FIXED.sql`) if needed.
- Example with supabase CLI (assuming logged in):
  supabase db remote set <db-connection-url>
  psql <db-connection-url> -f db/migrations/001_add_chat_fields_and_rls_FIXED.sql

Do NOT commit service_role keys or DB credentials to the repository.
