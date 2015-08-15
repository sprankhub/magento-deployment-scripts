<?php

/**
 * This APC cache clearing script is based on http://stackoverflow.com/a/3580939/719023 and should be called by
 * apc_clear_call.php.
 */

if (function_exists('apc_clear_cache')) {
    apc_clear_cache();
    apc_clear_cache('user');
    apc_clear_cache('opcode');
    echo json_encode(array('success' => true));
}
