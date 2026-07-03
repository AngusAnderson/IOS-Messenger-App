from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, EmailOTP, Device, OneTimePreKey


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    ordering = ["id"]
    list_display = ["id", "email", "is_staff", "is_superuser", "is_active"]
    search_fields = ["email"]
    fieldsets = (
        (None, {"fields": ("email", "password")}),
        ("Permissions", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
        ("Important dates", {"fields": ("last_login", "created_at")}),
    )
    add_fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ("email", "password1", "password2", "is_staff", "is_superuser", "is_active"),
        }),
    )
    filter_horizontal = ("groups", "user_permissions")


@admin.register(EmailOTP)
class EmailOTPAdmin(admin.ModelAdmin):
    list_display = ["email", "code", "created_at", "expires_at", "is_used"]
    search_fields = ["email", "code"]
    list_filter = ["is_used"]


@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ["id", "user", "created_at", "last_seen"]
    search_fields = ["user__email"]


@admin.register(OneTimePreKey)
class OneTimePreKeyAdmin(admin.ModelAdmin):
    list_display = ["id", "device", "key_id", "used", "created_at"]
    list_filter = ["used"]
