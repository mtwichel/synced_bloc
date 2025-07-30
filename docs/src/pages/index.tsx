import Link from '@docusaurus/Link';
import { useColorMode } from '@docusaurus/theme-common';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import clsx from 'clsx';

import styles from './index.module.css';

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx('hero', styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">{siteConfig.title}</h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <HomepageCTA />
        <HomepageHeroImage />
      </div>
    </header>
  );
}

export default function Home(): JSX.Element {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      description={`The official documentation site for Blocsync. ${siteConfig.tagline}.`}
    >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}

function HomepageCTA() {
  return (
    <div className={styles.width}>
      <Link className="button button--primary button--lg" to="/docs/quickstart">
        Get Started
      </Link>
    </div>
  );
}

function HomepageHeroImage() {
  const { colorMode } = useColorMode();
  return (
    <img
      className={clsx(styles.heroImage)}
      src={colorMode == 'dark' ? 'img/hero_dark.svg' : 'img/hero.svg'}
      alt="Hero"
      width="720"
    />
  );
}

type FeatureItem = {
  title: string;
  Image: string;
  description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Works with flutter_bloc',
    Image: '/img/pillar1.png',
    description: (
      <>
        Works with <a href="https://bloclibrary.dev">Flutter Bloc</a> out of the
        box. Just extend <code>SyncedBloc</code> or <code>SyncedCubit</code>!
      </>
    ),
  },
  {
    title: 'Pillar 2',
    Image: '/img/pillar1.png',
    description: (
      <>
        Quis hendrerit dolor magna eget est. Urna nunc id cursus metus aliquam.
        Id faucibus nisl tincidunt eget nullam non nisi est sit.
      </>
    ),
  },
  {
    title: 'Pillar 3',
    Image: '/img/pillar1.png',
    description: (
      <>
        Tempor orci dapibus ultrices in iaculis nunc sed augue. Convallis tellus
        id interdum velit laoreet id donec ultrices tincidunt.
      </>
    ),
  },
];

function Feature({ title, Image, description }: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <img
          src={Image}
          alt={title}
          style={{ width: '120px', height: 'auto' }}
        />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
