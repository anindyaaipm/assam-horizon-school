/**
 * Shared Supabase Client Initialization
 * This file initializes a single Supabase client instance for use across all pages
 */

(function() {
    'use strict';

    // Supabase configuration
    const SUPABASE_URL = 'https://mrthnvwokprolhaoimpg.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ydGhudndva3Byb2xoYW9pbXBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNzExODYsImV4cCI6MjA3NDY0NzE4Nn0.5nncUpTZXKEMC65Bdcr5JRmzulUZRHWrRhPbVLV8Tzo';

    // Initialize Supabase client only once
    if (typeof window.supabaseClient === 'undefined') {
        // Wait for Supabase library to be available
        function initSupabaseClient() {
            if (typeof window.supabase !== 'undefined' && window.supabase.createClient) {
                try {
                    window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
                    console.log('Supabase client initialized successfully');
                    
                    // Dispatch custom event to notify that Supabase is ready
                    window.dispatchEvent(new CustomEvent('supabaseReady'));
                } catch (error) {
                    console.error('Error initializing Supabase client:', error);
                    window.supabaseClient = null;
                }
            } else {
                // Retry after a short delay if Supabase library isn't loaded yet
                setTimeout(initSupabaseClient, 100);
            }
        }

        // Start initialization
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initSupabaseClient);
        } else {
            initSupabaseClient();
        }
    }

    // Export for use in other scripts
    window.getSupabaseClient = function() {
        return window.supabaseClient || null;
    };
})();

