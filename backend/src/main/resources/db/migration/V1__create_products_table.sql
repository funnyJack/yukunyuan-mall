-- ============================================================
-- V1：商品表
-- 金额统一用「分」存 bigint，category 存枚举名（FOOD/HOME/...）
-- ============================================================

create table products (
    id          varchar(36)              not null,
    title       varchar(30)              not null,
    description varchar(200)             not null,
    price_cents bigint                   not null,
    category    varchar(16)              not null,
    seller_name varchar(30)              not null,
    stock       integer                  not null default 0,
    created_at  timestamp with time zone not null,
    updated_at  timestamp with time zone not null,

    constraint pk_products primary key (id),
    constraint ck_products_price_cents check (price_cents >= 0),
    constraint ck_products_stock check (stock >= 0)
);

comment on table products is '商品表';
comment on column products.id is '商品 ID（种子数据用 p1..p12，上架商品用 UUID）';
comment on column products.title is '商品名称';
comment on column products.description is '商品描述';
comment on column products.price_cents is '价格，单位：分；0 表示面议';
comment on column products.category is '分类枚举名：FOOD/HOME/DIGITAL/CLOTHING/HANDMADE/OTHER';
comment on column products.seller_name is '店铺名称';
comment on column products.stock is '库存，0 表示已售罄';
comment on column products.created_at is '创建时间（UTC）';
comment on column products.updated_at is '更新时间（UTC）';

-- 列表按分类筛选、按创建时间倒序分页
create index idx_products_category on products (category);
create index idx_products_created_at on products (created_at desc);
