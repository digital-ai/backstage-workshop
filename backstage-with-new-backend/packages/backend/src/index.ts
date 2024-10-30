/*
 * Hi!
 *
 * Note that this is an EXAMPLE Backstage backend. Please check the README.
 *
 * Happy hacking!
 */

import { createBackend } from '@backstage/backend-defaults';
import {createBackendModule} from "@backstage/backend-plugin-api";
import {PermissionPolicy, PolicyQuery} from "@backstage/plugin-permission-node";
import {BackstageIdentityResponse} from "@backstage/plugin-auth-node";
import {AuthorizeResult, isPermission, PolicyDecision} from "@backstage/plugin-permission-common";
import {catalogConditions, createCatalogConditionalDecision} from "@backstage/plugin-catalog-backend/alpha";
import {policyExtensionPoint} from "@backstage/plugin-permission-node/alpha";
import {
    catalogEntityDeletePermission,
} from '@backstage/plugin-catalog-common/alpha';
import {
    daiDeployViewPermission
} from "@digital-ai/plugin-dai-deploy-common";

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@backstage/plugin-proxy-backend'));
backend.add(import('@backstage/plugin-scaffolder-backend'));
backend.add(import('@backstage/plugin-techdocs-backend'));

// auth plugin
backend.add(import('@backstage/plugin-auth-backend'));
// See https://backstage.io/docs/backend-system/building-backends/migrating#the-auth-plugin
backend.add(import('@backstage/plugin-auth-backend-module-guest-provider'));
// See https://backstage.io/docs/auth/guest/provider

// catalog plugin
backend.add(import('@backstage/plugin-catalog-backend'));
backend.add(
  import('@backstage/plugin-catalog-backend-module-scaffolder-entity-model'),
);

// permission plugin
backend.add(import('@backstage/plugin-permission-backend'));

// search plugin
backend.add(import('@backstage/plugin-search-backend'));
backend.add(import('@backstage/plugin-search-backend-module-catalog'));
backend.add(import('@backstage/plugin-search-backend-module-techdocs'));
backend.add(import('@digital-ai/plugin-dai-deploy-backend'));

class CustomPermissionPolicy implements PermissionPolicy {
    async handle(
        request: PolicyQuery,
        user?: BackstageIdentityResponse,
    ): Promise<PolicyDecision> {

        if (isPermission(request.permission, catalogEntityDeletePermission)) {
            return createCatalogConditionalDecision(
                request.permission,
                catalogConditions.isEntityOwner({
                    claims: user?.identity.ownershipEntityRefs ?? []
                }),

            );
        }
        if (isPermission(request.permission, daiDeployViewPermission)) {
            return createCatalogConditionalDecision(
                request.permission,
                catalogConditions.isEntityOwner({
                    claims: user?.identity.ownershipEntityRefs ?? []
                }),
            );
        }

        return { result: AuthorizeResult.ALLOW };
    }
}

const customPermissionBackendModule = createBackendModule({
    pluginId: 'permission',
    moduleId: 'custom-policy',
    register(reg) {
        reg.registerInit({
            deps: { policy: policyExtensionPoint },
            async init({ policy }) {
                policy.setPolicy(new CustomPermissionPolicy());
            },
        });
    },
});
backend.add(customPermissionBackendModule);
backend.add(import('@digital-ai/plugin-dai-release-backend'));

backend.start();
