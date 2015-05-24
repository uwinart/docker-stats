#!/usr/bin/env tarantool

box.cfg {
  listen = 3311,
  logger = '/data/tarantool/stats.tarantool.log',
  snap_dir = '/data/tarantool',
  sophia_dir = '/data/tarantool',
  wal_dir = '/data/tarantool'
}

require('console').listen('127.0.0.1:3312')

-- Создаем дополнительные функции
dofile('/data/tarantool/assets/next_id.lua')
dofile('/data/tarantool/assets/utils.lua')

--[[ Создаем, если ранее не было создано пространство sessions
    1: id, 2: site_id, 3: user_hash, 4: user_id, 5: begin_date, 6: end_date,
    7: language, 8: screen_width, 9: screen_height, 10: screen_depth,
    11: screen_pixelRation, 12: device_type, 13: device_manufacturer,
    14: os_family, 15: os_major, 16: os_minor, 17: browser_family,
    18: browser_major, 19: browser_minor, 20: begin_url, 21: end_url,
    22: referer_type, 23: referer_source, 24: referer_domain, 25: referer_url,
    26: ip, 27: country_code, 28: region, 29: city
]]
sessions = box.schema.space.create('sessions', {if_not_exists = true})
sessions:create_index('primary',
  {type = 'hash', parts = {1, 'NUM'}, if_not_exists = true})


--[[ Создаем, если ранее не было создано пространство hits
    1: id, 2: site_id, 3: session_id, 4: user_hash, 5: user_id,
    6: begin_date, 7: end_date, 8: time_request, 9: load_request,
    10: dom_content_loaded, 11: load_page, 12: page_url,
    13: subject, 14: subject_id, 15: subject_synonym
]]
hits = box.schema.space.create('hits', {if_not_exists = true})
hits:create_index('primary',
  {type = 'hash', parts = {1, 'NUM'}, if_not_exists = true})
-- hits by subject and synonym
hits:create_index('synonyms',
  {parts = {13, 'STR', 15, 'STR'}, if_not_exists = true, unique = false})
-- hits by subject and date
hits:create_index('times',
  {parts = {6, 'NUM'}, if_not_exists = true, unique = false})

-- Раздаем всем права {{{
local _schema_id = box.space._schema.id
local sessions_id = box.space.sessions.id
local hits_id = box.space.hits.id
local guest_id = box.space._user.index.name:get{'guest'}[1]
local _priv = box.space._priv

if #_priv.index.primary:select({guest_id, 'space', _schema_id}) == 0 then
  box.schema.user.grant('guest','read,write','space','_schema')
end

if #_priv.index.primary:select({guest_id, 'space', sessions_id}) == 0 then
  box.schema.user.grant('guest','read,write','space','sessions')
end

if #_priv.index.primary:select({guest_id, 'space', hits_id}) == 0 then
  box.schema.user.grant('guest','read,write','space','hits')
end
-- }}}

print('Starting "Stats" tarantool space')
