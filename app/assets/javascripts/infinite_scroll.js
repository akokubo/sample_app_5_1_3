/*jslint browser:true */
/*global $, window */

// references
// https://www.sitepoint.com/infinite-scrolling-rails-basics/
$(document).on("ready turbolinks:load", function () {
    "use strict";
    var isLoading = false;
    // #infinite-scrolling要素の個数が0より大きければ
    if ($("#infinite-scrolling").size() > 0) {
        // ウィンドウがスクロールしたとき
        $(window).on("scroll", function () {
            // マイクロポストの次のページへのリンクを取得
            var more_microposts_url = $(".pagination .next_page a").attr("href");
            // ロード中でなく、次のページへのリンクが存在し、ページの最下部 - 60pxまでスクロールしたら
            if (!isLoading && more_microposts_url && $(window).scrollTop() > $(document).height() - $(window).height() - 60) {
                // ロード中にする
                isLoading = true;
                // ローダーイメージを表示
                $("#loader").show();
                // 次のページを取得
                $.getScript(more_microposts_url).done(function () {
                    // ローダーイメージを非表示
                    $("#loader").hide();
                    // ロードしていないにする
                    isLoading = false;
                }).fail(function () {
                  // ローダーイメージを非表示
                  $("#loader").hide();
                  // ロードしていないにする
                  isLoading = false;
                });
            }
        });
    }
});
