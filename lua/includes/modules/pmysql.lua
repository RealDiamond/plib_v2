-- NOTE:
-- This module depreciated and is just a means of basic backwards compatibility.
-- Require ptmysql or pmysqloo not this module!!

require('putil')

if file.Exists('lua/bin/gmsv_mysqloo_win32.dll', 'MOD') then
	require('pmysqloo')
	pmysql = pmysqloo
elseif file.Exists('lua/bin/gmsv_tmysql4_win32.dll', 'MOD') then
	require('ptmysql')
	pmysql = ptmysql
end