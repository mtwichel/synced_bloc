// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer').themes.vsLight;
const darkCodeTheme = require('prism-react-renderer').themes.vsDark;

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Blocsync',
  tagline: 'A bloc that syncs its state to the cloud. ',
  url: 'https://docs.blocsyncer.com',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'mtwichel', // Usually your GitHub org/user name.
  projectName: 'blocsync', // Usually your repo name.

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/mtwichel/blocsync/tree/main/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'Blocsync',
        logo: {
          alt: 'Docs Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'doc',
            docId: 'quickstart',
            position: 'left',
            label: 'Get Started',
          },
          {
            href: 'https://github.com/mtwichel/blocsync',
            position: 'right',
            className: 'navbar-github-icon',
            'aria-label': 'GitHub repository',
          },
        ],
      },
      footer: {
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Quickstart',
                to: '/docs/quickstart',
              },
              {
                label: 'Basics',
                to: '/docs/category/basics',
              },
              {
                label: 'Authentication',
                to: '/docs/category/authentication',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/mtwichel/blocsync',
              },
            ],
          },
        ],
      },
      prism: {
        additionalLanguages: ['bash', 'dart', 'yaml'],
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
