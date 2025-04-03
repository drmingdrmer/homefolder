module.exports = {
  env: {
    browser: true,
    es2021: true,
    webextensions: true,  // 添加Chrome扩展API支持
  },
  extends: 'eslint:recommended',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',  // 支持import/export
  },
  rules: {
    // 错误检测规则（针对重构和变量使用）
    'no-undef': 'error',              // 未定义变量
    'no-unused-vars': 'warn',         // 未使用的变量
    'no-param-reassign': 'warn',      // 参数重新赋值
    'func-call-spacing': ['error', 'never'], // 函数调用间距
    'prefer-const': 'warn',           // 建议使用const
    'no-use-before-define': ['error', { 'functions': false }], // 变量在定义前不能使用

    // 格式规则
    'indent': ['warn', 2],              // 缩进
    'semi': ['warn', 'always'],         // 分号
    'quotes': ['warn', 'single'],       // 引号
    'comma-dangle': ['warn', 'always-multiline'], // 尾随逗号
  },
  // 针对特定文件的规则
  overrides: [
    {
      files: ['*.js'],
      rules: {},
    },
  ],
  // 全局变量定义
  globals: {
    'chrome': 'readonly',
  },
};
