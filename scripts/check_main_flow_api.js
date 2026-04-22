/* eslint-disable no-console */
const fs = require('fs');
const path = require('path');

const ROOT_DIR = process.cwd();

const checks = [
  {
    name: '登录',
    frontend: [
      { file: 'services/auth/index.js', pattern: "/api/auth/login" }
    ],
    backend: [
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/auth/controller/ClinicAuthApiController.java',
        pattern: '@PostMapping("/login")'
      }
    ]
  },
  {
    name: '配置同步',
    frontend: [
      { file: 'services/config/index.js', pattern: "/api/clinic/config/get" },
      { file: 'services/config/index.js', pattern: "/api/clinic/config/version" }
    ],
    backend: [
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/config/controller/ClinicConfigApiController.java',
        pattern: '@GetMapping("/get")'
      },
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/config/controller/ClinicConfigApiController.java',
        pattern: '@GetMapping("/version")'
      }
    ]
  },
  {
    name: 'AI 聊天',
    frontend: [
      { file: 'services/ai/index.js', pattern: "/api/clinic/ai/chat/send" }
    ],
    backend: [
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/ai/controller/ClinicAiChatApiController.java',
        pattern: '@PostMapping("/send")'
      }
    ]
  },
  {
    name: '药品识别',
    frontend: [
      { file: 'services/medicine-recognition/index.js', pattern: "/api/clinic/medicine/recognize/code" },
      { file: 'services/medicine-recognition/index.js', pattern: "/api/clinic/medicine/recognize/confirm" },
      { file: 'services/medicine-recognition/index.js', pattern: "/api/clinic/medicine/recognize/history" }
    ],
    backend: [
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/medicine/controller/ClinicMedicineApiController.java',
        pattern: '@PostMapping("/recognize/code")'
      },
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/medicine/controller/ClinicMedicineApiController.java',
        pattern: '@PostMapping("/recognize/confirm")'
      },
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/medicine/controller/ClinicMedicineApiController.java',
        pattern: '@GetMapping("/recognize/history")'
      }
    ]
  },
  {
    name: '新建药品',
    frontend: [
      { file: 'services/medicine/index.js', pattern: "/api/clinic/medicine/add" }
    ],
    backend: [
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/medicine/controller/ClinicMedicineApiController.java',
        pattern: '@PostMapping("/add")'
      }
    ]
  },
  {
    name: '药品入库',
    frontend: [
      { file: 'services/medicine/index.js', pattern: "/api/clinic/stock/add" }
    ],
    backend: [
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/medicine/controller/ClinicStockRecordApiController.java',
        pattern: '@PostMapping(value = "/add", consumes = MediaType.APPLICATION_JSON_VALUE)'
      }
    ]
  },
  {
    name: '会话安全',
    frontend: [
      { file: 'services/auth/index.js', pattern: "/api/auth/session/list" },
      { file: 'services/auth/index.js', pattern: "/api/auth/session/kickout" },
      { file: 'services/auth/index.js', pattern: "/api/auth/session/kickoutOthers" }
    ],
    backend: [
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/auth/controller/ClinicAuthApiController.java',
        pattern: '@GetMapping("/session/list")'
      },
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/auth/controller/ClinicAuthApiController.java',
        pattern: '@PostMapping("/session/kickout")'
      },
      {
        file: 'springboot/src/main/java/com/ruoyi/project/clinic/auth/controller/ClinicAuthApiController.java',
        pattern: '@PostMapping("/session/kickoutOthers")'
      }
    ]
  }
];

const runtimeProbes = [
  { name: '登录接口', method: 'POST', path: '/api/auth/login', body: { username: '13800000000', password: 'invalid' } },
  { name: '配置读取', method: 'GET', path: '/api/clinic/config/get' },
  { name: 'AI 能力探测', method: 'GET', path: '/api/clinic/ai/chat/capability' },
  { name: '识别历史', method: 'GET', path: '/api/clinic/medicine/recognize/history?limit=1' },
  { name: '新建药品', method: 'POST', path: '/api/clinic/medicine/add', body: {} },
  { name: '药品入库', method: 'POST', path: '/api/clinic/stock/add', body: {} },
  { name: '会话列表', method: 'GET', path: '/api/auth/session/list' }
];

function parseArgs(argv) {
  const options = {
    baseUrl: '',
    timeoutMs: 8000
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--base-url' && argv[i + 1]) {
      options.baseUrl = argv[i + 1].trim();
      i += 1;
      continue;
    }
    if (arg.startsWith('--base-url=')) {
      options.baseUrl = arg.split('=').slice(1).join('=').trim();
      continue;
    }
    if (arg === '--timeout' && argv[i + 1]) {
      options.timeoutMs = Number(argv[i + 1]) || options.timeoutMs;
      i += 1;
      continue;
    }
    if (arg.startsWith('--timeout=')) {
      options.timeoutMs = Number(arg.split('=').slice(1).join('=')) || options.timeoutMs;
    }
  }

  return options;
}

function readFileCached(cache, relativePath) {
  if (cache.has(relativePath)) {
    return cache.get(relativePath);
  }
  const absolutePath = path.join(ROOT_DIR, relativePath);
  if (!fs.existsSync(absolutePath)) {
    cache.set(relativePath, null);
    return null;
  }
  const content = fs.readFileSync(absolutePath, 'utf8');
  cache.set(relativePath, content);
  return content;
}

function runStaticCheck() {
  const fileCache = new Map();
  const missing = [];

  checks.forEach((item) => {
    [...item.frontend, ...item.backend].forEach((target) => {
      const content = readFileCached(fileCache, target.file);
      if (!content || !content.includes(target.pattern)) {
        missing.push({
          flow: item.name,
          file: target.file,
          pattern: target.pattern
        });
      }
    });
  });

  return missing;
}

function joinUrl(baseUrl, requestPath) {
  const left = baseUrl.replace(/\/+$/, '');
  const right = requestPath.startsWith('/') ? requestPath : `/${requestPath}`;
  return `${left}${right}`;
}

async function runtimeProbe(baseUrl, timeoutMs) {
  if (!baseUrl) {
    return [];
  }
  if (typeof fetch !== 'function') {
    return [{
      name: '运行时探测',
      url: baseUrl,
      ok: false,
      reason: '当前 Node 环境不支持 fetch，无法执行运行时探测。'
    }];
  }

  const results = [];
  for (const probe of runtimeProbes) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    const url = joinUrl(baseUrl, probe.path);
    try {
      const response = await fetch(url, {
        method: probe.method,
        headers: {
          'Content-Type': 'application/json'
        },
        body: probe.method === 'GET' ? undefined : JSON.stringify(probe.body || {}),
        signal: controller.signal
      });
      clearTimeout(timer);

      const status = Number(response.status || 0);
      const ok = status > 0 && status < 500 && status !== 404;
      results.push({
        name: probe.name,
        url,
        method: probe.method,
        status,
        ok,
        reason: ok ? '' : `状态码 ${status} 不符合预期（允许 2xx/3xx/401/403/4xx，禁止 404/5xx）。`
      });
    } catch (error) {
      clearTimeout(timer);
      results.push({
        name: probe.name,
        url,
        method: probe.method,
        ok: false,
        reason: error && error.name === 'AbortError'
          ? `请求超时（>${timeoutMs}ms）`
          : (error && error.message) || '请求失败'
      });
    }
  }
  return results;
}

function printStaticResult(missing) {
  console.log(`\n[main-flow-api-check] root=${ROOT_DIR}`);
  console.log(`[main-flow-api-check] static checks: ${checks.length}`);
  console.log(`[main-flow-api-check] missing mappings: ${missing.length}`);

  if (missing.length > 0) {
    console.log('\n[static-missing]');
    missing.forEach((item) => {
      console.log(`- [${item.flow}] ${item.file} :: ${item.pattern}`);
    });
  } else {
    console.log('\n[static] 主流程前后端接口映射检查通过。');
  }
}

function printRuntimeResult(results, baseUrl) {
  if (!baseUrl) {
    console.log('\n[runtime] 未传入 --base-url，已跳过运行时探测。');
    return;
  }
  console.log(`\n[runtime] base-url=${baseUrl}`);
  const failed = results.filter((item) => !item.ok);
  results.forEach((item) => {
    const statusText = item.status ? `status=${item.status}` : 'status=n/a';
    console.log(`- ${item.ok ? 'PASS' : 'FAIL'} ${item.method || ''} ${item.url} (${statusText}) ${item.reason || ''}`.trim());
  });
  console.log(`[runtime] failed probes: ${failed.length}`);
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const missing = runStaticCheck();
  printStaticResult(missing);

  const runtimeResults = await runtimeProbe(options.baseUrl, options.timeoutMs);
  printRuntimeResult(runtimeResults, options.baseUrl);

  const runtimeFailed = runtimeResults.some((item) => !item.ok);
  if (missing.length > 0 || runtimeFailed) {
    console.error('\n[main-flow-api-check] failed.');
    return 1;
  }

  console.log('\n[main-flow-api-check] passed.');
  return 0;
}

main().catch((error) => {
  console.error('[main-flow-api-check] unexpected error:', error);
  return 1;
}).then((code) => {
  process.exitCode = Number.isInteger(code) ? code : 1;
});
