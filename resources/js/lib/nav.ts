import { NavItem, Role } from '@/types';
import { RouteDefinition } from '@/wayfinder';
import admin from '@/wayfinder/routes/admin';
import { LayoutGrid, Users } from 'lucide-react';

export function getMainNavItems(role: Role): NavItem[] {
    const items = [
        {
            title: 'Dashboard',
            icon: LayoutGrid,
        },
        {
            title: 'Users',
            icon: Users,
        },
    ];

    const hrefsByRole: Record<
        string,
        Record<string, RouteDefinition<'get'> | string>
    > = {
        admin: {
            Dashboard: admin.dashboard(),
            Users: admin.users.index(),
        },
    };

    return items.map((item) => ({
        ...item,
        href: hrefsByRole[role][item.title],
    }));
}
