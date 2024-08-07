import { createRouter } from "@digital-ai/plugin-dai-release-backend";
import { Router } from 'express';
import { PluginEnvironment } from '../types';

export default async function createPlugin(
    env: PluginEnvironment,
): Promise<Router> {
    // Here is where you will add all of the required initialization code that
    // your backend plugin needs to be able to start!

    // The env contains a lot of goodies, but our router currently only
    // needs a logger
    return await createRouter({
        logger: env.logger,
        config: env.config,
        permissions: env.permissions
    });
}