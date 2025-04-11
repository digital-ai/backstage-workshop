import React, { PropsWithChildren } from 'react';
import { makeStyles } from '@material-ui/core';
import HomeIcon from '@material-ui/icons/Home';
import ExtensionIcon from '@material-ui/icons/Extension';
import MapIcon from '@material-ui/icons/MyLocation';
import LibraryBooks from '@material-ui/icons/LibraryBooks';
import CreateComponentIcon from '@material-ui/icons/AddCircleOutline';
import {
  Settings as SidebarSettings,
  UserSettingsSignInAvatar,
} from '@backstage/plugin-user-settings';
import { SidebarSearchModal } from '@backstage/plugin-search';
import {
  Sidebar,
  sidebarConfig,
  SidebarDivider,
  SidebarGroup,
  SidebarItem,
  SidebarPage,
  SidebarScrollWrapper,
  SidebarSpace,
  useSidebarOpenState,
  SidebarSubmenu,
  SidebarSubmenuItem,
  Link,
} from '@backstage/core-components';
import MenuIcon from '@material-ui/icons/Menu';
import SearchIcon from '@material-ui/icons/Search';
import {ReleaseSvgIcon} from '@digital-ai/plugin-dai-release'
import '@digital-ai/dot-icons/index.css';
import DigitalAILogoFull from './logo/digital-ai-reverse-logo.png';
import DigitalAILogoIcon from './logo/digital-ai-favicon-reverse.png';

export const templateIcon = () => {
return (
  <span className="dot-icon">
  <i className="icon-template"/>
  </span>
  );
};
export const activeReleaseIcon = () => {
return (
  <span className="dot-icon">
  <i className="icon-release"/>
  </span>
  );
}
export const workflowIcon = () => {
  return (
      <span className="dot-icon">
  <i className="icon-workflow"/>
  </span>
  );
}

const useSidebarLogoStyles = makeStyles({
  root: {
    width: sidebarConfig.drawerWidthClosed,
    height: 3 * sidebarConfig.logoHeight,
    display: 'flex',
    flexFlow: 'row nowrap',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: -28,
  },
  link: {
    width: sidebarConfig.drawerWidthClosed,
    marginLeft: 20,
  },
});

const BackedByBackstage = () => {
  const {isOpen} = useSidebarOpenState();
  const useStyles = makeStyles({
    text: {
      width: sidebarConfig.drawerWidthOpen,
      color: '#b5b5b5',
      display: 'flex',
      fontSize: '10px',
      marginLeft: 35,
      minHeight: '14px',
    },
  });

  const classes = useStyles();

  return (
      <div className={classes.text}>
        {isOpen ? <div>&copy; Backed by Backstage</div> : ''}
      </div>
  );
};

const LogoFull = () => {
  const svg = {
    width: 'auto',
    height: 50,
    marginLeft: 10,
  }
  return <img src={DigitalAILogoFull} style={svg} alt="Digital.ai"/>;
};

const LogoIcon = () => {
  const svg = {
    width: 'auto',
    height: 40,
  }
  return <img src={DigitalAILogoIcon} style={svg} alt="Digital.ai"/>;
};

const SidebarLogo = () => {
  const classes = useSidebarLogoStyles();
  const { isOpen } = useSidebarOpenState();

  return (
    <div className={classes.root}>
      <Link to="/" underline="none" className={classes.link} aria-label="Home">
        {isOpen ? <LogoFull /> : <LogoIcon />}
      </Link>
    </div>
  );
};

export const Root = ({ children }: PropsWithChildren<{}>) => (
  <SidebarPage>
    <Sidebar>
      <SidebarLogo />
      <BackedByBackstage/>
      <SidebarGroup label="Search" icon={<SearchIcon />} to="/search">
        <SidebarSearchModal />
      </SidebarGroup>
      <SidebarDivider />
      <SidebarGroup label="Menu" icon={<MenuIcon />}>
        {/* Global nav, not org-specific */}
        <SidebarItem icon={HomeIcon} to="catalog" text="Home" />
        <SidebarItem icon={ExtensionIcon} to="api-docs" text="APIs" />
        <SidebarItem icon={LibraryBooks} to="docs" text="Docs" />
        <SidebarItem icon={CreateComponentIcon} to="create" text="Create..." />
        {/* End global nav */}
        <SidebarDivider />
        <SidebarScrollWrapper>
        <SidebarItem icon={ReleaseSvgIcon} onClick={() => {}} text="digital.ai Release">
        <SidebarSubmenu title="Release">
          <SidebarSubmenuItem
          title="Active releases"
          to="dai-release"
          icon={activeReleaseIcon}
          />
          <SidebarSubmenuItem
          title="Templates"
          to="dai-template"
          icon={templateIcon}
          />
          <SidebarSubmenuItem
              title="Workflows"
              to="/dai-workflows"
              icon={workflowIcon}
          />
        </SidebarSubmenu>
        </SidebarItem>
          {/* <SidebarItem icon={ReleaseSvgIcon} to="dai-release" text="digital.ai release" />*/}
        </SidebarScrollWrapper>
        <SidebarDivider />
        <SidebarScrollWrapper>
          <SidebarItem icon={MapIcon} to="tech-radar" text="Tech Radar" />
        </SidebarScrollWrapper>
      </SidebarGroup>
      <SidebarSpace />
      <SidebarDivider />
      <SidebarGroup
        label="Settings"
        icon={<UserSettingsSignInAvatar />}
        to="/settings"
      >
        <SidebarSettings />
      </SidebarGroup>
    </Sidebar>
    {children}
  </SidebarPage>
);
