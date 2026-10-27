import test from 'node:test';
import assert from 'node:assert/strict';
import net from 'node:net';
import { readFileSync } from 'node:fs';
import { apply, probePort } from '../src/index.js';

test('probe distinguishes listening and closed ports', async () => {
  const server=net.createServer(socket=>socket.end());
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  const port=server.address().port;
  try { assert.equal(await probePort(port),true); }
  finally { await new Promise(resolve=>server.close(resolve)); }
  assert.equal(await probePort(port),false);
  assert.throws(()=>probePort(65536),/Invalid port/);
});

test('profile without tools service can load',()=>{
  let disposed=false;
  apply({effect(fn){ const dispose=fn();dispose();disposed=true; }});
  assert.equal(disposed,true);
});

test('tool registration, guide, invalid input and disposal',async()=>{
  let tool,cleanup,disposed=false;
  apply({tools:{register(t){tool=t;return()=>{disposed=true}}},effect(fn){cleanup=fn()}});
  assert.equal(tool.name,'napcat_deploy_check');
  const result=await tool.execute({mode:'guide'});
  assert.match(result.text,/不自动启动QQ/);
  assert.equal(tool.output.render({},result)[0].text,result.text);
  await assert.rejects(tool.execute({mode:'launch'}),/mode must/);
  cleanup();assert.equal(disposed,true);
});

test('public package manifest has explicit file allowlist and no install lifecycle',()=>{
  const pkg=JSON.parse(readFileSync(new URL('../package.json',import.meta.url),'utf8'));
  assert.equal(pkg.dsh.bundle.patch,'./cordis.patch.yml');
  assert.ok(!pkg.files.includes('config.local.json'));
  assert.ok(!pkg.files.includes('runtime'));
  assert.equal(pkg.scripts.postinstall,undefined);
});
