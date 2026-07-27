<?php

namespace Database\Seeders;

use App\Enums\Role as ERole;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $roles = ERole::toArray();

        foreach ($roles as $role) {
            if (Role::where('name', $role)->exists()) {
                continue;
            }

            Role::create([
                'name' => $role,
                'guard_name' => 'web',
            ]);
        }

        User::create([
            'first_name' => 'Cashwise',
            'middle_name' => null,
            'last_name' => 'Admin',
            'email' => 'admin@cashwise.com',
            'password' => bcrypt('password'),
        ])->assignRole(ERole::ADMIN->value);
    }
}
