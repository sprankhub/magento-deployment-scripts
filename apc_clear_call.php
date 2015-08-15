<?php

/**
 * This APC cache clearing script is based on http://stackoverflow.com/a/3580939/719023.
 */

$requiredOptions = array('url', 'htmlroot', 'scriptroot');
$options         = getopt('', array('url:', 'htmlroot:', 'scriptroot:'));

// check if all required options are given
if (count(array_intersect_key(array_flip($requiredOptions), $options)) !== count($requiredOptions)) {
    echo 'Could not clear APC cache since some required options are missing' . PHP_EOL;
    exit;
}

$url        = rtrim($options['url'], '/');
$htmlRoot   = rtrim($options['htmlroot'], '/');
$scriptRoot = rtrim($options['scriptroot'], '/');

copy($scriptRoot . '/apc_clear.php', $htmlRoot . '/apc_clear.php');

$scriptUrl = $url . '/apc_clear.php';
$result    = json_decode(file_get_contents($scriptUrl), true);

if (isset($result['success']) && $result['success']) {
    echo 'APC cache cleared' . PHP_EOL;
} else {
    echo 'Could not clear APC cache' . PHP_EOL;
}

unlink($htmlRoot . '/apc_clear.php');
