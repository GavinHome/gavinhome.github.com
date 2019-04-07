{% extends '_layout.swig' %}

{% block pageCss %}
    {{ css('scss/views/portfolio/fluidbox.min.css') }}
    <!--{{ css('scss/views/portfolio/styles.css') }}-->
    {{ css('scss/views/portfolio/index') }}
    {{ css('scss/views/portfolio/responsive.css') }}
{% endblock %}

{% block header %}
    {% include './_partial/common/small-header.swig' %}
{% endblock %}

{% block main %}
    {% include './_partial/portfolio/main.swig' %}
{% endblock %}

{% block pagejs %}
    {{ js('js/portfolio/jquery-3.2.1.min.js') }}
    {{ js('js/portfolio/tether.min.js') }}
    {{ js('js/portfolio/isotope.pkgd.min.js') }}
    {{ js('js/portfolio/jquery.fluidbox.min.js') }}
    {{ js('js/portfolio/scripts.js') }}
{% endblock %}