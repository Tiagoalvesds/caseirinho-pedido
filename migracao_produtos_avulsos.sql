-- ============================================================
-- MIGRAÇÃO: produtos avulsos (bebidas, sorvetes, doces)
-- Diferente do "cardápio da semana": sem dia da semana (sempre
-- disponível) e com preço individual por item (não por prato).
-- Idempotente.
-- ============================================================

create table if not exists produtos_avulsos (
  id uuid primary key default gen_random_uuid(),
  categoria text not null,
  nome text not null,
  preco numeric(10,2) not null,
  ativo boolean not null default true,
  ordem_categoria integer not null default 0,
  ordem_item integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_produtos_avulsos_categoria on produtos_avulsos(categoria);

drop trigger if exists trg_produtos_avulsos_updated_at on produtos_avulsos;
create trigger trg_produtos_avulsos_updated_at
  before update on produtos_avulsos
  for each row execute function set_updated_at();

alter table produtos_avulsos enable row level security;

drop policy if exists "leitura publica produtos avulsos" on produtos_avulsos;
drop policy if exists "dono edita produtos avulsos" on produtos_avulsos;

create policy "leitura publica produtos avulsos" on produtos_avulsos for select using (true);
create policy "dono edita produtos avulsos" on produtos_avulsos for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ---------- Seed: 88 itens em 21 categorias ----------
-- Só insere o que ainda não existir (compara por categoria+nome), então
-- é seguro rodar de novo sem duplicar caso você já tenha adicionado algo.

insert into produtos_avulsos (categoria, nome, preco, ordem_categoria, ordem_item)
select v.categoria, v.nome, v.preco, v.ordem_categoria, v.ordem_item
from (values
  ('BEBIDAS', 'Suco de caixinha 200ml (pêssego, uva e caju)', 4.00, 1, 1),
  ('BEBIDAS', 'Guaraná Mineiro 200ml (vidro)', 5.00, 1, 2),
  ('BEBIDAS', 'Guaraná Mineiro 250ml (PET)', 5.00, 1, 3),
  ('ÁGUAS', 'Água com gás (500ml)', 5.00, 2, 1),
  ('ÁGUAS', 'Água sem gás (500ml)', 4.00, 2, 2),
  ('ÁGUAS', 'Água sem gás (1,5L)', 10.00, 2, 3),
  ('ÁGUAS', 'Água tônica (azul e branca)', 8.00, 2, 4),
  ('BEBIDAS LATAS', 'Coca-Cola lata (zero e normal)', 7.00, 3, 1),
  ('BEBIDAS LATAS', 'Guaraná Antarctica (zero e normal)', 7.00, 3, 2),
  ('BEBIDAS LATAS', 'Guaraná Mineiro (zero e normal)', 7.00, 3, 3),
  ('BEBIDAS LATAS', 'Fanta Laranja', 7.00, 3, 4),
  ('BEBIDAS LATAS', 'Suco lata (pêssego e uva)', 7.00, 3, 5),
  ('BEBIDAS LATAS', 'Sprite (normal)', 7.00, 3, 6),
  ('BEBIDAS LATAS', 'Pepsi Black (zero)', 7.00, 3, 7),
  ('BEBIDAS LATAS', 'Extra Power (latão 473ml)', 11.00, 3, 8),
  ('BEBIDAS KS (VIDRO)', 'Fanta Laranja', 7.00, 4, 1),
  ('BEBIDAS KS (VIDRO)', 'Coca-Cola (zero e normal)', 7.00, 4, 2),
  ('BEBIDAS 600ML', 'Coca-Cola (zero e normal)', 10.00, 5, 1),
  ('BEBIDAS 600ML', 'Guaraná Antarctica', 10.00, 5, 2),
  ('BEBIDAS 600ML', 'Guaraná Mineiro (normal PET e vidro)', 10.00, 5, 3),
  ('BEBIDAS 600ML', 'H2OH Limoneto', 10.00, 5, 4),
  ('BEBIDAS 1L', 'Suco (pêssego e uva)', 12.00, 6, 1),
  ('BEBIDAS 1L', 'Coca-Cola (zero e normal)', 12.00, 6, 2),
  ('BEBIDAS 1L', 'Fanta Laranja', 12.00, 6, 3),
  ('BEBIDAS 1L', 'Guaraná Antarctica (normal)', 12.00, 6, 4),
  ('BEBIDAS 1L', 'Extra Power (1,25L)', 18.00, 6, 5),
  ('BEBIDA DE 1,5L', 'Guaraná Mineiro', 14.00, 7, 1),
  ('BEBIDA DE 2L', 'Pepsi Black (zero)', 17.00, 8, 1),
  ('CERVEJAS', 'Heineken (600 ml)', 18.90, 9, 1),
  ('CERVEJAS', 'Original (600 ml)', 17.90, 9, 2),
  ('CERVEJAS', 'Amstel (600 ml)', 17.90, 9, 3),
  ('CERVEJAS', 'Antarctica (600 ml)', 17.90, 9, 4),
  ('CERVEJAS', 'Brahma (600 ml)', 16.90, 9, 5),
  ('Picolés Premium', 'Pistache', 7.00, 10, 1),
  ('Picolés Premium', 'Café', 8.00, 10, 2),
  ('Picolés Premium', 'Açaí Leitinho', 10.00, 10, 3),
  ('Picolés Premium', 'Belga', 10.00, 10, 4),
  ('Picolés Premium', 'Cookies', 10.00, 10, 5),
  ('Picolés Premium', 'Clássico', 10.00, 10, 6),
  ('Picolés Premium', 'Black 70%', 10.00, 10, 7),
  ('Linha Especial', 'Brigadeiro Doce de Leite (açaí com leitinho)', 10.00, 11, 1),
  ('Linha Especial', 'Brigadeiro', 9.00, 11, 2),
  ('Linha Especial', 'Crocante', 9.00, 11, 3),
  ('Linha Especial', 'Napolitano', 7.00, 11, 4),
  ('Linha Especial', 'Triplo', 7.00, 11, 5),
  ('Linha Tradicional', 'Super Black', 9.00, 12, 1),
  ('Linha Tradicional', 'Leitito', 9.00, 12, 2),
  ('Linha Tradicional', 'Eskimó', 7.00, 12, 3),
  ('Linha Tradicional', 'Limão Suíço', 6.50, 12, 4),
  ('Linha Tradicional', 'Sensação', 6.50, 12, 5),
  ('Linha Tradicional', 'Leitinho com Morango', 6.50, 12, 6),
  ('Linha Tradicional', 'Morango', 6.50, 12, 7),
  ('Linha Tradicional', 'Abacaxi', 6.50, 12, 8),
  ('Picolés de Fruta', 'Groselha', 3.50, 13, 1),
  ('Picolés de Fruta', 'Limão', 3.50, 13, 2),
  ('Picolés de Fruta', 'Uva', 3.50, 13, 3),
  ('Picolés de Fruta', 'Cajá', 5.00, 13, 4),
  ('Picolés Cremosos', 'Chocolate', 4.50, 14, 1),
  ('Picolés Cremosos', 'Milho Verde', 4.50, 14, 2),
  ('Picolés Cremosos', 'Coco Queimado', 4.50, 14, 3),
  ('Picolés Cremosos', 'Nata Cremosa', 4.50, 14, 4),
  ('Açaí no Copo', 'Açaí Banana', 11.00, 15, 1),
  ('Açaí no Copo', 'Açaí Guaraná', 11.00, 15, 2),
  ('Açaí no Copo', 'Açaí Avelã', 12.50, 15, 3),
  ('Açaí no Copo', 'Açaí Leitinho', 30.00, 15, 4),
  ('Açaí no Copo', 'Açaí com Whey Zero Açúcar (20 g de proteína)', 30.00, 15, 5),
  ('Açaí no Pote', 'Açaí Guaraná – 1 L', 32.00, 16, 1),
  ('Açaí no Pote', 'Açaí Guaraná – 3,6 L', 110.00, 16, 2),
  ('Açaí no Pote', 'Açaí Leitinho – 5 L', 40.00, 16, 3),
  ('Açaí no Pote', 'Açaí Leitinho com Cookies & Cream – Pote', 38.00, 16, 4),
  ('Açaí no Pote', 'Açaí Banana – Pote', 38.00, 16, 5),
  ('Picolé de Açaí', 'Açaí Banana', 6.50, 17, 1),
  ('Picolés Infantil', 'Marshmallow', 5.00, 18, 1),
  ('Picolés Infantil', 'Estrelinha', 5.00, 18, 2),
  ('Potes de Sorvete', 'Look (com pedaços crocantes)', 18.00, 19, 1),
  ('Potes de Sorvete', 'SNIQ Ice Cream', 16.00, 19, 2),
  ('Potes de Sorvete', 'Cherry Mania (500 ml)', 16.00, 19, 3),
  ('Potes de Sorvete', 'Par Perfeito Beijinho com Morango (1,6 L)', 28.00, 19, 4),
  ('Potes de Sorvete', 'Par Perfeito Pudim de Caramelo (1,6 L)', 28.00, 19, 5),
  ('Potes de Sorvete', 'Par Perfeito Trufadinho (1,6 L)', 28.00, 19, 6),
  ('Potes de Sorvete', 'Zero Adição de Açúcar Napolitano (1 L)', 26.00, 19, 7),
  ('Sorvetes 1 Litro', 'Ferretti Chocolat', 30.00, 20, 1),
  ('Sorvetes 1 Litro', 'Creme de Avelã', 30.00, 20, 2),
  ('Sorvetes 1 Litro', 'Coco Bianco', 30.00, 20, 3),
  ('Doces', 'Todos os doces expostos (cada)', 4.00, 21, 1),
  ('Doces', 'Sachê de Doce de Leite', 3.00, 21, 2),
  ('Doces', 'Babaloo (unidade)', 0.50, 21, 3),
  ('Doces', 'Chiclets (unidade)', 0.25, 21, 4)
) as v(categoria, nome, preco, ordem_categoria, ordem_item)
where not exists (
  select 1 from produtos_avulsos p
  where p.categoria = v.categoria and p.nome = v.nome
);
