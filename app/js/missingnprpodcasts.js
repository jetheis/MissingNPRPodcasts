/**
 * Missing NPR Podcasts
 * Copyright 2012 Jimmy Theis (MIT License)
 *
 * Unimified file at <https://github.com/jetheis/MissingNPRPodcasts/blob/master/app/js/missingnprpodcasts.js>
 **/

(function() {
    'use strict';

    // HAML sucks sometimes, so it's easier to just set the targets to all links
    // with JavaScript (which should have no negative effect on things like scraping)
    $('a').not('.btn').attr('target', '_blank');

    var storage = window.localStorage,
        storageKey = 'missingNprPodcastsApiKey';

    var subscriptionsContainer = $('.subscriptions');

    var apiKeyField = $('#apiKeyField'),
        apiKeyCheckButton = $('#apiKeyCheckButton'),
        apiForm = $('#apiForm');

    var morningEditionITunesButton = $('#morningEditionITunesButton'),
        morningEditionRssButton = $('#morningEditionRssButton');

    var allThingsConsideredITunesButton = $('#allThingsConsideredITunesButton'),
        allThingsConsideredRssButton = $('#allThingsConsideredRssButton');

    function attachGoogleAnalyticsEvents() {
        function clickHandler(button) { return function() { _gaq.push(['_trackEvent', button, 'click']); }; }
        morningEditionITunesButton.click(clickHandler('Morning Edition iTunes Button'));
        morningEditionRssButton.click(clickHandler('Morning Edition RSS Button'));
        allThingsConsideredITunesButton.click(clickHandler('All Things Considered iTunes Button'));
        allThingsConsideredRssButton.click(clickHandler('All Things Considered RSS Button'));

        apiKeyCheckButton.click(function() { _gaq.push(['_trackEvent', 'Validate API Key Button', 'click']); });
    }

    function attemptToRestoreKey() {
        if (storage && storage[storageKey]) {
            _gaq.push(['_trackEvent', 'API Key', 'Restored']);
            apiKeyField.val(storage[storageKey]);
            apiKeyCheckButton.click();
        }
    }

    function storeKey(key) {
        if (storage) {
            storage[storageKey] = key;
        }
    }

    function disableValidateButton() {
        apiKeyCheckButton.attr('disabled', true);
        apiKeyCheckButton.text('Validating...');
    }

    function enableValidateButton() {
        apiKeyCheckButton.removeAttr('disabled');
        apiKeyCheckButton.text('Validate API Key');
    }

    function validate(e) {

        e.preventDefault();

        disableValidateButton();

        var baseUrl = window.location.host + window.location.pathname,
            baseProtocol = window.location.protocol + '//',
            iTunesProtocol = 'itpc://',
            apiKey = apiKeyField.val();

        $.getJSON('testapikey?key=' + apiKey, null, function(data) {

            if (data.hasOwnProperty('validKey') && data.validKey === true) {

                _gaq.push(['_trackEvent', 'API Key', 'Validated']);

                // Build URLs for the various buttons
                var morningEditionBaseUrl = baseUrl + 'podcasts/morningedition?key=' + apiKey,
                    morningEditionITunesUrl = iTunesProtocol + morningEditionBaseUrl,
                    morningEditionRssUrl = baseProtocol + morningEditionBaseUrl;

                var allThingsConsideredBaseUrl = baseUrl + 'podcasts/allthingsconsidered?key=' + apiKey,
                    allThingsConsideredITunesUrl = iTunesProtocol + allThingsConsideredBaseUrl,
                    allThingsConsideredRssUrl = baseProtocol + allThingsConsideredBaseUrl;

                // Apply the new URLs
                morningEditionITunesButton.attr('href', morningEditionITunesUrl);
                morningEditionRssButton.attr('href', morningEditionRssUrl);

                allThingsConsideredITunesButton.attr('href', allThingsConsideredITunesUrl);
                allThingsConsideredRssButton.attr('href', allThingsConsideredRssUrl);

                // Make the buttons visible
                subscriptionsContainer.removeClass('hidden');

                // Make sure we're scrolled to the bottom
                var body = $('body')[0];
                body.scrollTop = body.scrollHeight;

                // Revert to original button text
                enableValidateButton();

                // Store the key for use next time
                storeKey(apiKey);

            } else {

                _gaq.push(['_trackEvent', 'API Key', 'Failed to Validate']);

                window.alert('The API key you entered does not appear to be valid. Please double check it and try again.');
                enableValidateButton();
            }
        });
    }

    attachGoogleAnalyticsEvents();

    apiKeyCheckButton.click(validate);
    apiForm.submit(validate);

    // Restore an old key if one's available
    attemptToRestoreKey();

}());
