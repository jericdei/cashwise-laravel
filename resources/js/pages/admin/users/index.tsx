import users from '@/wayfinder/routes/admin/users';
import { Head } from '@inertiajs/react';

export default function Index() {
    return (
        <>
            <Head title="Users" />
        </>
    );
}

Index.layout = {
    breadcrumbs: [
        {
            title: 'Users',
            href: users.index(),
        },
    ],
};
