/* Executes the actual non-UI ArkTS modules after TypeScript erasure; platform APIs are mocked. */
const fs = require('fs'), path = require('path'), vm = require('vm'), assert = require('assert/strict');
const ts = require(path.join(require('./deveco-path.cjs')(), 'tools/hvigor/hvigor/node_modules/typescript'));
const root = path.resolve(__dirname, '..'), source = path.join(root, 'products/default/src/main/ets');
let cache, calls, responder, vault;
const asset = { Tag: { ALIAS: 1, SECRET: 2, RETURN_TYPE: 3, RETURN_LIMIT: 4, ACCESSIBILITY: 5, AUTH_TYPE: 6, CONFLICT_RESOLUTION: 7 },
  ReturnType: { ALL: 1 }, Accessibility: { DEVICE_UNLOCKED: 1 }, AuthType: { NONE: 1 }, ConflictResolution: { OVERWRITE: 1 }, ErrorCode: { NOT_FOUND: 404 },
  query: async () => vault ? [new Map(vault)] : [], add: async value => { vault = new Map(value); }, remove: async () => { vault = null; } };
const http = { RequestMethod: { GET: 'GET', POST: 'POST', PUT: 'PUT', DELETE: 'DELETE' }, HttpDataType: { OBJECT: 1 },
  createHttp: () => ({ request: async (url, options) => { const call = { url, ...options }; calls.push(call); return responder(call); }, destroy() {} }) };
const kits = { '@kit.NetworkKit': { http }, '@kit.AssetStoreKit': { asset }, '@kit.ArkTS': { util: {
  TextEncoder: class { encodeInto(text) { return new TextEncoder().encode(text); } },
  TextDecoder: class { decodeToString(bytes) { return new TextDecoder().decode(bytes); } }
} } };
function load(name, parent = source) {
  if (kits[name]) return kits[name];
  const file = path.resolve(parent, name.endsWith('.ets') ? name : name + '.ets');
  if (cache.has(file)) return cache.get(file).exports;
  const module = { exports: {} }; cache.set(file, module);
  const result = ts.transpileModule(fs.readFileSync(file, 'utf8'), { compilerOptions: { target: ts.ScriptTarget.ES2021, module: ts.ModuleKind.CommonJS } });
  vm.runInThisContext('(function(require,module,exports){' + result.outputText + '\n})', { filename: file })(n => load(n, path.dirname(file)), module, module.exports);
  return module.exports;
}
const raw = { userId: '9007199254740993123', username: 'test', nickname: '测试昵称', email: null, phone: null, department: null, avatar: null };
const auth = (suffix = '1') => ({ accessToken: 'access-' + suffix, refreshToken: 'refresh-' + suffix, tokenType: 'Bearer', expiresIn: 3600, user: raw });
const ok = data => ({ responseCode: 200, result: { code: 200, message: 'success', data } });
const failure = (code, message = 'expected failure') => ({ responseCode: 200, result: { code, message, data: null } });
function reset(keepVault = false) { cache = new Map(); calls = []; if (!keepVault) vault = null; responder = async call => ok(call.url.includes('/auth/') ? auth() : raw); }
function session() { return load('session/SessionManager').SessionManager.getInstance(); }
function client() { return load('api/httpClient').HttpClient.getInstance(); }
const tests = [];
function test(name, fn) { tests.push({ name, fn }); }
test('profile: nullable fields and large string ID', () => {
  const p = load('api/BackendAdapters').adaptProfile(raw);
  assert.equal(p.id, raw.userId); assert.equal(p.name, raw.nickname); assert.equal(p.phone, ''); assert.equal(p.email, '');
});
test('profile: omit empty phone, reject unsupported unbinding', () => {
  const api = load('api/BackendAdapters'), draft = { name: '昵称', email: 'd@example.com', phone: '', department: '部门' };
  assert.deepEqual(api.profileBody(draft, ''), { nickname: '昵称', email: 'd@example.com', department: '部门' });
  assert.throws(() => api.profileBody(draft, '13800000000'), /解绑/);
});
test('storage: MB conversion and distinct denominator percentages', () => {
  const a = load('api/BackendAdapters'), s = a.adaptStorage({ totalSpace: 10240, usedSpace: 2048, usagePercentage: 20,
    storageBreakdown: [{ type: 'project', used: 1024, percentage: 50, count: 1 }] });
  assert.equal(s.totalSpace, '10.00 GB'); assert.equal(s.usedSpace, '2.00 GB'); assert.equal(s.details[0].percent, 10); assert.equal(s.details[0].usedPercent, 50);
  const zero = a.adaptStorage({ totalSpace: 0, usedSpace: 0, usagePercentage: 0, storageBreakdown: [{ type: 'other', used: 0, percentage: 0, count: 0 }] });
  assert.equal(zero.details[0].percent, 0); assert.equal(zero.details[0].usedPercent, 0);
});
test('uploads: preserve all actual states and string IDs', () => {
  for (const status of ['pending', 'completed', 'failed', 'rejected']) {
    const r = load('api/BackendAdapters').adaptUpload({ id: raw.userId, fileName: 'f', fileSize: null, uploadTime: '2026-10-17', uploadStatus: status, uploadProgress: 0 });
    assert.equal(r.status, status); assert.equal(r.id, raw.userId);
  }
});
test('login: account contract and Bearer authorization', async () => {
  await session().login({ account: 'test', password: 'test-only' }, false);
  assert.deepEqual(JSON.parse(calls[0].extraData), { account: 'test', password: 'test-only' });
  assert.equal(calls[0].header.Authorization, undefined);
  await load('api/userApi').fetchUserProfile(); assert.equal(calls[1].header.Authorization, 'Bearer access-1');
});
test('profile update: backend nickname body and null result', async () => {
  responder = async () => ok(null);
  const r = await load('api/userApi').updateUserProfile({ name: '新昵称', email: 'd@example.com', phone: '', department: '部门' });
  assert.equal(r.data, null); assert.equal(JSON.parse(calls[0].extraData).nickname, '新昵称');
  assert.equal(JSON.parse(calls[0].extraData).name, undefined);
});
test('pagination: pageSize/list adapter and current-user sharer', async () => {
  responder = async () => ok({ list: [{ id: raw.userId, fileName: 'f', shareTime: '2026-10-17' }], total: 11, page: 2, pageSize: 10 });
  const r = await load('api/shareApi').fetchSharedRecords(2, 10, '当前用户');
  assert(calls[0].url.endsWith('?page=2&pageSize=10')); assert.equal(r.data.items[0].sharedBy, '当前用户'); assert.equal(r.data.total, 11);
});
test('DELETE: clearAll in JSON body', async () => {
  responder = async () => ok({ deletedCount: 0 }); await load('api/uploadApi').clearUploadRecords();
  assert.equal(calls[0].method, 'DELETE'); assert.deepEqual(JSON.parse(calls[0].extraData), { clearAll: true });
});
test('business failure: rejected without refresh', async () => {
  responder = async () => failure(400, '手机号格式不正确');
  await assert.rejects(() => client().get('/user/profile'), e => e.kind === 'business' && e.message === '手机号格式不正确'); assert.equal(calls.length, 1);
});
test('HTTP 403: rejected without refresh', async () => {
  responder = async () => ({ responseCode: 403, result: { message: '无权限' } });
  await assert.rejects(() => client().get('/user/profile'), e => e.kind === 'http' && e.httpStatus === 403); assert.equal(calls.length, 1);
});
test('network/timeout: classified, bounded and not retried', async () => {
  responder = async () => { throw Error('platform timeout'); };
  await assert.rejects(() => client().get('/user/profile'), e => e.kind === 'network');
  assert.equal(calls.length, 1); assert.equal(calls[0].connectTimeout, 10000); assert.equal(calls[0].readTimeout, 10000);
});
test('malformed response: explicit response failure', async () => {
  responder = async () => ({ responseCode: 200, result: '<html>' });
  await assert.rejects(() => client().get('/user/profile'), e => e.kind === 'response');
});
test('401: one token rotation and one retry', async () => {
  await session().login({ account: 'test', password: 'test-only' }, false);
  responder = async c => c.url.endsWith('/auth/refresh') ? ok(auth('2')) : c.header.Authorization === 'Bearer access-1' ? failure(401) : ok(raw);
  await load('api/userApi').fetchUserProfile();
  assert.equal(calls.filter(c => c.url.endsWith('/auth/refresh')).length, 1); assert.equal(client().getToken(), 'access-2');
});
test('concurrent 401: one shared refresh', async () => {
  await session().login({ account: 'test', password: 'test-only' }, false);
  responder = async c => {
    if (c.url.endsWith('/auth/refresh')) { await new Promise(r => setTimeout(r, 10)); return ok(auth('2')); }
    return c.header.Authorization === 'Bearer access-1' ? failure(401) : ok(raw);
  };
  await Promise.all([client().get('/user/profile'), client().get('/user/profile'), client().get('/user/profile')]);
  assert.equal(calls.filter(c => c.url.endsWith('/auth/refresh')).length, 1);
});
test('expired access token: proactive single refresh', async () => {
  await session().login({ account: 'test', password: 'test-only' }, false); client().rotateToken('access-1', Date.now() - 1);
  responder = async c => c.url.endsWith('/auth/refresh') ? ok(auth('2')) : ok(raw);
  await client().get('/user/profile'); assert.equal(calls[1].url.endsWith('/auth/refresh'), true);
});
test('second 401: no retry loop and local expiry', async () => {
  await session().login({ account: 'test', password: 'test-only' }, true);
  responder = async c => c.url.endsWith('/auth/refresh') ? ok(auth('2')) : failure(401);
  await assert.rejects(() => client().get('/user/profile')); assert.equal(client().getToken(), ''); assert.equal(vault, null);
  assert.equal(calls.filter(c => c.url.endsWith('/user/profile')).length, 2);
});
test('refresh failure: local logout', async () => {
  await session().login({ account: 'test', password: 'test-only' }, true); responder = async () => failure(401);
  await assert.rejects(() => client().get('/user/profile')); assert.equal(client().getToken(), ''); assert.equal(vault, null);
});
test('remembered cold start: refresh, rotate and restore', async () => {
  await session().login({ account: 'test', password: 'test-only' }, true); assert(vault);
  reset(true); responder = async c => c.url.endsWith('/auth/refresh') ? ok(auth('2')) : ok(raw);
  const user = await session().restore(); assert.equal(user.name, raw.nickname); assert.equal(client().getToken(), 'access-2');
  assert.equal(JSON.parse(calls[0].extraData).refreshToken, 'refresh-1');
});
test('not remembered: cold start remains logged out', async () => {
  await session().login({ account: 'test', password: 'test-only' }, false); assert.equal(vault, null);
  reset(true); assert.equal(await session().restore(), null); assert.equal(calls.length, 0);
});
test('logout: revoke refresh token and clear secure storage', async () => {
  await session().login({ account: 'test', password: 'test-only' }, true); responder = async () => ok(null);
  const result = await session().logout(); assert.equal(result.remoteRevoked, true); assert.equal(result.storageCleared, true);
  assert.equal(vault, null); assert.equal(client().getToken(), ''); assert.deepEqual(JSON.parse(calls[1].extraData), { refreshToken: 'refresh-1' });
});
test('logout racing in-flight data: stale response rejected', async () => {
  await session().login({ account: 'test', password: 'test-only' }, true);
  let release; responder = async c => c.url.endsWith('/auth/logout') ? ok(null) : new Promise(r => { release = () => r(ok(raw)); });
  const pending = client().get('/user/profile'); await session().logout(); release();
  await assert.rejects(() => pending, e => e.kind === 'unauthorized'); assert.equal(client().getToken(), '');
});
test('logout racing refresh: stale auth cannot resurrect session', async () => {
  await session().login({ account: 'test', password: 'test-only' }, true);
  let release; responder = async c => c.url.endsWith('/auth/refresh') ? new Promise(r => { release = () => r(ok(auth('2'))); }) : ok(null);
  const pending = session().refreshSession(); await session().logout(); release();
  await assert.rejects(() => pending); assert.equal(client().getToken(), ''); assert.equal(vault, null);
});
(async () => {
  const results = [];
  for (const t of tests) { reset(); try { await t.fn(); results.push({ name: t.name, passed: true }); console.log('PASS ' + t.name); }
    catch (e) { results.push({ name: t.name, passed: false, error: e.message }); console.error('FAIL ' + t.name + ': ' + e.message); } }
  fs.mkdirSync(path.join(root, 'validation'), { recursive: true });
  fs.writeFileSync(path.join(root, 'validation/unit-results.json'), JSON.stringify({ passed: results.filter(x => x.passed).length, total: results.length, results }, null, 2));
  if (results.some(x => !x.passed)) process.exitCode = 1;
})();
