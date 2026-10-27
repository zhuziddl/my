import net from 'node:net';

export const name = 'napcat-deploy';
// Optional: a profile layer can be loaded before an agent tools service exists.
export const inject = { optional: ['tools'] };

export function probePort(port, timeoutMs = 600) {
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new TypeError('Invalid port');
  return new Promise((resolve) => {
    const socket = new net.Socket();
    const finish = (open) => { socket.destroy(); resolve(open); };
    socket.setTimeout(timeoutMs);
    socket.once('connect', () => finish(true));
    socket.once('error', () => finish(false));
    socket.once('timeout', () => finish(false));
    socket.connect(port, '127.0.0.1');
  });
}

const guide = [
  '安装部署包：从仓库获取Install.ps1、Start.cmd、Start.ps1和config.example.json。',
  '从NapCat官方v4.18.41发布页下载NapCat.Shell.zip，执行Install.ps1 -ArchivePath <ZIP绝对路径>。',
  '在config.local.json中填写本机QQ.exe路径及自己的账号，不在聊天中提交账号、令牌或登录态。',
  '由用户双击Start.cmd并确认管理员权限提示，扫码登录；保持窗口运行。',
  '在NapCat中启用仅本机的OneBot正向WebSocket服务端，在DSH OneBot适配器配置相同端口及令牌。',
  '本插件只提供部署指南与TCP监听检查，不替代dsh-onebot，不自动启动QQ、不提权、不读取私聊。',
  '端口监听不能证明账号在线或聊天可用，最终需要用户实际收发验证。',
].join('\n');

export function apply(ctx) {
  ctx.effect(() => {
    if (typeof ctx.tools?.register !== 'function') return () => {};
    const dispose = ctx.tools.register({
      name: 'napcat_deploy_check',
      description: '读取NapCat部署指南，或只读检查127.0.0.1固定端口3001/6099是否监听。不会启动QQ、提权或读取账户与令牌。',
      parameters: {
        type: 'object', additionalProperties: false,
        properties: { mode: { type: 'string', enum: ['guide', 'status'] } }, required: ['mode'],
      },
      output: {
        schema: {
          type: 'object', additionalProperties: false,
          properties: { text: { type: 'string' } }, required: ['text'],
        },
        render: (_args, value) => [{ type: 'text', text: value.text }],
      },
      async execute(args) {
        if (args?.mode === 'guide') return { text: guide };
        if (args?.mode !== 'status') throw new Error('mode must be guide or status');
        const [onebot, webui] = await Promise.all([probePort(3001), probePort(6099)]);
        return { text: `本机TCP监听：3001=${onebot ? '有监听' : '无监听'}，6099=${webui ? '有监听' : '无监听'}。仅为默认端口检查，未核对协议、身份、登录或消息投递。若使用自定义端口，请按本机配置检查。` };
      },
      presentCall: (args) => ({ card: 'generic', title: 'NapCat 部署检查', kind: 'other', rawInput: args.mode }),
    });
    return dispose;
  }, 'napcat-deploy.tools');
}
