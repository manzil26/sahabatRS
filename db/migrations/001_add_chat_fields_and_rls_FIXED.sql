-- Migrasi: 0001_add_chat_fields_and_rls_FIXED.sql
-- Versi tetap menggunakan nama kolom pg_policies yang benar 'policyname'.
BEGIN;

-- 1) Tambahkan kolom baru
ALTER TABLE public.chat
  ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'text',
  ADD COLUMN IF NOT EXISTS attachment_url TEXT,
  ADD COLUMN IF NOT EXISTS delivered_at timestamptz,
  ADD COLUMN IF NOT EXISTS read_at timestamptz;

-- 2) Tambahkan batasan FK ke auth.users (jika belum ada)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chat_sender_id_fkey') THEN
    ALTER TABLE public.chat
      ADD CONSTRAINT chat_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chat_receiver_id_fkey') THEN
    ALTER TABLE public.chat
      ADD CONSTRAINT chat_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES auth.users(id);
  END IF;
END$$;

-- 3) Tambahkan indeks untuk meningkatkan kinerja
CREATE INDEX IF NOT EXISTS idx_chat_sender_receiver_created ON public.chat (sender_id, receiver_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_created_at ON public.chat (created_at DESC);

-- 4) Aktifkan Keamanan Tingkat Baris dan tambahkan kebijakan
ALTER TABLE public.chat ENABLE ROW LEVEL SECURITY;

-- Izinkan peserta untuk MEMILIH pesan di mana mereka berperan sebagai pengirim atau penerima
DO $$
BEGIN
  -- PERBAIKAN: gunakan 'policyname' kolom pada pg_policies
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_chat_for_participants' AND tablename = 'chat') THEN
    CREATE POLICY select_chat_for_participants ON public.chat
      FOR SELECT
      USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
  END IF;

  -- Izinkan penyisipan hanya jika auth.uid() == sender_id
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'insert_chat_for_sender' AND tablename = 'chat') THEN
    CREATE POLICY insert_chat_for_sender ON public.chat
      FOR INSERT
      WITH CHECK (auth.uid() = sender_id);
  END IF;

  -- Izinkan pembaruan hanya untuk peserta
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'update_chat_for_participants' AND tablename = 'chat') THEN
    CREATE POLICY update_chat_for_participants ON public.chat
      FOR UPDATE
      USING (auth.uid() = sender_id OR auth.uid() = receiver_id)
      WITH CHECK (auth.uid() = sender_id OR auth.uid() = receiver_id);
  END IF;
END$$;

COMMIT;
