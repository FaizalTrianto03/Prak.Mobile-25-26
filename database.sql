-- Buat tabel notes
create table notes (
  id bigint primary key generated always as identity,
  title text not null,
  content text not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Contoh data awal (opsional)
insert into notes (title, content)
values
  ('Catatan Pertama', 'Ini isi catatan pertama.'),
  ('Catatan Kedua', 'Contoh catatan kedua.');

-- Aktifkan Row Level Security
alter table notes enable row level security;

-- Kebijakan untuk anonymous hanya bisa baca (opsional)
create policy "Public can read notes"
on public.notes
for select
to anon
using (true);

-- Kebijakan CRUD lengkap untuk pengguna terautentikasi
create policy "Authenticated users can read notes"
on notes
for select
to authenticated
using (true);

create policy "Authenticated users can insert notes"
on notes
for insert
to authenticated
with check (true);

create policy "Authenticated users can update notes"
on notes
for update
to authenticated
using (true)
with check (true);

create policy "Authenticated users can delete notes"
on notes
for delete
to authenticated
using (true);

-- Tambah kolom untuk menyimpan lokasi file gambar di Supabase Storage
ALTER TABLE notes
ADD COLUMN image_path TEXT;

-- Pastikan bucket sudah ada
insert into storage.buckets (id, name, public)
values ('note-images', 'note-images', true)
on conflict (id) do update set public = true;

-- Izinkan semua pengguna terautentikasi mengelola file mereka pada bucket note-images
create policy "Authenticated users can manage own note images"
on storage.objects
for all
to authenticated
using (
  bucket_id = 'note-images'
  and auth.uid() = owner
)
with check (
  bucket_id = 'note-images'
  and auth.uid() = owner
);

-- (Opsional) jika ingin catatan bisa diakses publik,
-- izinkan siapa pun membaca file di bucket ini
create policy "Anyone can read note images"
on storage.objects
for select
to public
using (bucket_id = 'note-images');