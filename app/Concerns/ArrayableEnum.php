<?php

namespace App\Concerns;

use Illuminate\Support\Str;

/**
 * @property string $value
 * @property string $name
 */
trait ArrayableEnum
{
    abstract public static function cases(): array;

    /**
     * Get the enum values as an array.
     *
     * @return string[]
     */
    public static function toArray(): array
    {
        return array_column(self::cases(), 'value');
    }

    /**
     * Get the enum values as a map.
     *
     * @return array<string, string>
     *
     * @example [
     *     'active' => 'Active',
     *     'inactive' => 'Inactive',
     * ]
     */
    public static function toMap(): array
    {
        return collect(self::cases())
            ->mapWithKeys(fn (self $case) => [$case->value => Str::replace('_', ' ', Str::title($case->name))])
            ->all();
    }
}
