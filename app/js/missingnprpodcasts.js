/**
 * Missing NPR Podcasts
 * Copyright 2012 Jimmy Theis (MIT License)
 *
 * Unimified file at <>
 **/

(function() {
    'use strict';

    var subscriptionsContainer = $('.subscriptions');

    var apiKeyField = $('#apiKeyField'),
        apiKeyCheckButton = $('#apiKeyCheckButton'),
        apiForm = $('#apiForm');

    var morningEditionITunesButton = $('#morningEditionITunesButton'),
        morningEditionRssButton = $('#morningEditionRssButton');

    var allThingsConsideredITunesButton = $('#allThingsConsideredITunesButton'),
        allThingsConsideredRssButton = $('#allThingsConsideredRssButton');

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

                // Revert to original button text
                enableValidateButton();

            } else {
                alert('The API key you entered does not appear to be valid. Please double check it and try again.');
                enableValidateButton();
            }
        });
    }

    apiKeyCheckButton.click(validate);
    apiForm.submit(validate);

}());