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

    var weekendSundayITunesButton = $('#weekendSundayITunesButton'),
        weekendSundayRssButton = $('#weekendSundayRssButton');

    var weekendSaturdayITunesButton = $('#weekendSaturdayITunesButton'),
        weekendSaturdayRssButton = $('#weekendSaturdayRssButton');

    function attachGoogleAnalyticsEvents() {
        function clickHandler(button) { return function() {
            ga('send', 'event', button, 'click');
        }; }
        morningEditionITunesButton.click(clickHandler('Morning Edition iTunes Button'));
        morningEditionRssButton.click(clickHandler('Morning Edition RSS Button'));
        allThingsConsideredITunesButton.click(clickHandler('All Things Considered iTunes Button'));
        allThingsConsideredRssButton.click(clickHandler('All Things Considered RSS Button'));
        weekendSundayITunesButton.click(clickHandler('All Things Considered iTunes Button'));
        weekendSaturdayRssButton.click(clickHandler('All Things Considered RSS Button'));

        apiKeyCheckButton.click(function() {
            ga('send', 'event', 'Validate API Key Button', 'click');
        });
    }

    function attemptToRestoreKey() {
        if (storage && storage[storageKey]) {
            ga('send', 'event', 'API Key', 'Restored');
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

                ga('send', 'event', 'API Key', 'Validated');

                var binder = function(name, iTunesButton, rssButton) {
                    var commonUrl = baseUrl + 'podcasts/' + name + '?key=' + apiKey,
                        iTunesUrl = iTunesProtocol + commonUrl,
                        rssUrl = baseProtocol + commonUrl;

                    // Apply the new URLs
                    iTunesButton.attr('href', iTunesUrl);
                    rssButton.attr('href', rssUrl);
                };

                binder('morningedition', morningEditionITunesButton, morningEditionRssButton);
                binder('allthingsconsidered', allThingsConsideredITunesButton, allThingsConsideredRssButton);
                binder('weekendsunday', weekendSundayITunesButton, weekendSundayRssButton);
                binder('weekendsaturday', weekendSaturdayITunesButton, weekendSaturdayRssButton);

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

                ga('send', 'event', 'API Key', 'Failed to Validate');

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
