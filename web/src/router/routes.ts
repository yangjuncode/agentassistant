import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      {
        path: 'chat',
        name: 'chat',
        component: () => import('pages/ChatPage.vue'),
      },
      {
        path: '/',
        redirect: to => {
          to.path = '/chat'
          if (!to.query.token){
            to.query.token = 'test'
          }

          return to
        },
      }
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue'),
  },
];

export default routes;
