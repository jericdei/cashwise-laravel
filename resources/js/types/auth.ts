import type { App } from '@/wayfinder/types';

export type User = App.Models.User;
export type Role = App.Enums.Role;

export type Auth = {
    user: User;
    role: Role;
};

export type Passkey = {
    id: number;
    name: string;
    authenticator: string | null;
    created_at_diff: string;
    last_used_at_diff: string | null;
};
