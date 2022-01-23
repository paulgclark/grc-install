#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Top Block
# GNU Radio version: 3.8.2.0

from distutils.version import StrictVersion

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print("Warning: failed to XInitThreads()")

from PyQt5 import Qt
from gnuradio import eng_notation
from gnuradio import qtgui
from gnuradio.filter import firdes
import sip
from gnuradio import analog
from gnuradio import blocks
from gnuradio import channels
from gnuradio import digital
from gnuradio import filter
from gnuradio import gr
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
import reveng
import pmt
import satellites.hier

from gnuradio import qtgui

class top_block(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Top Block")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Top Block")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "top_block")

        try:
            if StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
                self.restoreGeometry(self.settings.value("geometry").toByteArray())
            else:
                self.restoreGeometry(self.settings.value("geometry"))
        except:
            pass

        ##################################################
        # Variables
        ##################################################
        self.symbol_rate = symbol_rate = 1/100e-6
        self.samp_rate = samp_rate = 2e6
        self.channel_width = channel_width = 50e3
        self.taps = taps = firdes.low_pass(1, samp_rate, channel_width/2, channel_width/10)
        self.squelch = squelch = -55
        self.sensitivity = sensitivity = 0.05
        self.samples_per_symbol = samples_per_symbol = int(samp_rate/symbol_rate)
        self.noise = noise = 0.01
        self.msg_str = msg_str = "It works!"
        self.freq = freq = 432.5e6
        self.center_freq = center_freq = 432e6

        ##################################################
        # Blocks
        ##################################################
        self._squelch_tool_bar = Qt.QToolBar(self)
        self._squelch_tool_bar.addWidget(Qt.QLabel('squelch' + ": "))
        self._squelch_line_edit = Qt.QLineEdit(str(self.squelch))
        self._squelch_tool_bar.addWidget(self._squelch_line_edit)
        self._squelch_line_edit.returnPressed.connect(
            lambda: self.set_squelch(eng_notation.str_to_num(str(self._squelch_line_edit.text()))))
        self.top_grid_layout.addWidget(self._squelch_tool_bar)
        self._sensitivity_tool_bar = Qt.QToolBar(self)
        self._sensitivity_tool_bar.addWidget(Qt.QLabel('sensitivity' + ": "))
        self._sensitivity_line_edit = Qt.QLineEdit(str(self.sensitivity))
        self._sensitivity_tool_bar.addWidget(self._sensitivity_line_edit)
        self._sensitivity_line_edit.returnPressed.connect(
            lambda: self.set_sensitivity(eng_notation.str_to_num(str(self._sensitivity_line_edit.text()))))
        self.top_grid_layout.addWidget(self._sensitivity_tool_bar)
        self._noise_tool_bar = Qt.QToolBar(self)
        self._noise_tool_bar.addWidget(Qt.QLabel('noise' + ": "))
        self._noise_line_edit = Qt.QLineEdit(str(self.noise))
        self._noise_tool_bar.addWidget(self._noise_line_edit)
        self._noise_line_edit.returnPressed.connect(
            lambda: self.set_noise(eng_notation.str_to_num(str(self._noise_line_edit.text()))))
        self.top_grid_layout.addWidget(self._noise_tool_bar)
        self._freq_tool_bar = Qt.QToolBar(self)
        self._freq_tool_bar.addWidget(Qt.QLabel('freq' + ": "))
        self._freq_line_edit = Qt.QLineEdit(str(self.freq))
        self._freq_tool_bar.addWidget(self._freq_line_edit)
        self._freq_line_edit.returnPressed.connect(
            lambda: self.set_freq(eng_notation.str_to_num(str(self._freq_line_edit.text()))))
        self.top_grid_layout.addWidget(self._freq_tool_bar)
        self.satellites_sync_to_pdu_packed_0 = satellites.hier.sync_to_pdu_packed(
            packlen=len(msg_str),
            sync="1010101010101010",
            threshold=0,
        )
        self.reveng_message_print_0 = reveng.message_print(2)
        self.qtgui_time_sink_x_0 = qtgui.time_sink_f(
            512, #size
            symbol_rate, #samp_rate
            "Received Baseband", #name
            1 #number of inputs
        )
        self.qtgui_time_sink_x_0.set_update_time(0.10)
        self.qtgui_time_sink_x_0.set_y_axis(-0.1, 1.1)

        self.qtgui_time_sink_x_0.set_y_label('Amplitude', "")

        self.qtgui_time_sink_x_0.enable_tags(True)
        self.qtgui_time_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_AUTO, qtgui.TRIG_SLOPE_POS, 0.5, 1e-4, 0, "")
        self.qtgui_time_sink_x_0.enable_autoscale(False)
        self.qtgui_time_sink_x_0.enable_grid(False)
        self.qtgui_time_sink_x_0.enable_axis_labels(True)
        self.qtgui_time_sink_x_0.enable_control_panel(False)
        self.qtgui_time_sink_x_0.enable_stem_plot(False)


        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ['blue', 'red', 'green', 'black', 'cyan',
            'magenta', 'yellow', 'dark red', 'dark green', 'dark blue']
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]
        styles = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        markers = [0, -1, -1, -1, -1,
            -1, -1, -1, -1, -1]


        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_time_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_time_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_time_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_time_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_time_sink_x_0.set_line_style(i, styles[i])
            self.qtgui_time_sink_x_0.set_line_marker(i, markers[i])
            self.qtgui_time_sink_x_0.set_line_alpha(i, alphas[i])

        self._qtgui_time_sink_x_0_win = sip.wrapinstance(self.qtgui_time_sink_x_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_time_sink_x_0_win)
        self.qtgui_sink_x_0_0 = qtgui.sink_c(
            1024, #fftsize
            firdes.WIN_BLACKMAN_hARRIS, #wintype
            freq, #fc
            samp_rate, #bw
            "Post-channel Filter", #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True #plotconst
        )
        self.qtgui_sink_x_0_0.set_update_time(1.0/10)
        self._qtgui_sink_x_0_0_win = sip.wrapinstance(self.qtgui_sink_x_0_0.pyqwidget(), Qt.QWidget)

        self.qtgui_sink_x_0_0.enable_rf_freq(True)

        self.top_grid_layout.addWidget(self._qtgui_sink_x_0_0_win)
        self.qtgui_sink_x_0 = qtgui.sink_c(
            1024, #fftsize
            firdes.WIN_BLACKMAN_hARRIS, #wintype
            center_freq, #fc
            samp_rate, #bw
            "Receiver Input", #name
            True, #plotfreq
            True, #plotwaterfall
            True, #plottime
            True #plotconst
        )
        self.qtgui_sink_x_0.set_update_time(1.0/10)
        self._qtgui_sink_x_0_win = sip.wrapinstance(self.qtgui_sink_x_0.pyqwidget(), Qt.QWidget)

        self.qtgui_sink_x_0.enable_rf_freq(True)

        self.top_grid_layout.addWidget(self._qtgui_sink_x_0_win)
        self.freq_xlating_fir_filter_xxx_0 = filter.freq_xlating_fir_filter_ccc(1, taps, freq-center_freq, samp_rate)
        self.digital_gfsk_mod_0 = digital.gfsk_mod(
            samples_per_symbol=samples_per_symbol,
            sensitivity=sensitivity,
            bt=0.35,
            verbose=False,
            log=False)
        self.digital_gfsk_demod_0 = digital.gfsk_demod(
            samples_per_symbol=samples_per_symbol,
            sensitivity=sensitivity,
            gain_mu=0.175,
            mu=0.5,
            omega_relative_limit=0.005,
            freq_error=0.0,
            verbose=True,
            log=False)
        self.channels_channel_model_0 = channels.channel_model(
            noise_voltage=noise,
            frequency_offset=0.0,
            epsilon=1.0,
            taps=[1.0 + 1.0j],
            noise_seed=0,
            block_tags=False)
        self.blocks_vector_source_x_0_0 = blocks.vector_source_b([0xAA, 0xAA]+list(ord(i) for i in msg_str)+1000*[0,], True, 1, [])
        self.blocks_uchar_to_float_0 = blocks.uchar_to_float()
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex*1, samp_rate,True)
        self.blocks_multiply_xx_0 = blocks.multiply_vcc(1)
        self.analog_sig_source_x_0 = analog.sig_source_c(samp_rate, analog.GR_COS_WAVE, freq-center_freq, 0.1, 0, 0)
        self.analog_pwr_squelch_xx_0 = analog.pwr_squelch_cc(squelch, 1, 0, False)



        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.satellites_sync_to_pdu_packed_0, 'out'), (self.reveng_message_print_0, 'msg_in'))
        self.connect((self.analog_pwr_squelch_xx_0, 0), (self.freq_xlating_fir_filter_xxx_0, 0))
        self.connect((self.analog_pwr_squelch_xx_0, 0), (self.qtgui_sink_x_0, 0))
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_multiply_xx_0, 1))
        self.connect((self.blocks_multiply_xx_0, 0), (self.channels_channel_model_0, 0))
        self.connect((self.blocks_throttle_0, 0), (self.analog_pwr_squelch_xx_0, 0))
        self.connect((self.blocks_uchar_to_float_0, 0), (self.qtgui_time_sink_x_0, 0))
        self.connect((self.blocks_vector_source_x_0_0, 0), (self.digital_gfsk_mod_0, 0))
        self.connect((self.channels_channel_model_0, 0), (self.blocks_throttle_0, 0))
        self.connect((self.digital_gfsk_demod_0, 0), (self.blocks_uchar_to_float_0, 0))
        self.connect((self.digital_gfsk_demod_0, 0), (self.satellites_sync_to_pdu_packed_0, 0))
        self.connect((self.digital_gfsk_mod_0, 0), (self.blocks_multiply_xx_0, 0))
        self.connect((self.freq_xlating_fir_filter_xxx_0, 0), (self.digital_gfsk_demod_0, 0))
        self.connect((self.freq_xlating_fir_filter_xxx_0, 0), (self.qtgui_sink_x_0_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "top_block")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_symbol_rate(self):
        return self.symbol_rate

    def set_symbol_rate(self, symbol_rate):
        self.symbol_rate = symbol_rate
        self.set_samples_per_symbol(int(self.samp_rate/self.symbol_rate))
        self.qtgui_time_sink_x_0.set_samp_rate(self.symbol_rate)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.set_samples_per_symbol(int(self.samp_rate/self.symbol_rate))
        self.set_taps(firdes.low_pass(1, self.samp_rate, self.channel_width/2, self.channel_width/10))
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)
        self.blocks_throttle_0.set_sample_rate(self.samp_rate)
        self.qtgui_sink_x_0.set_frequency_range(self.center_freq, self.samp_rate)
        self.qtgui_sink_x_0_0.set_frequency_range(self.freq, self.samp_rate)

    def get_channel_width(self):
        return self.channel_width

    def set_channel_width(self, channel_width):
        self.channel_width = channel_width
        self.set_taps(firdes.low_pass(1, self.samp_rate, self.channel_width/2, self.channel_width/10))

    def get_taps(self):
        return self.taps

    def set_taps(self, taps):
        self.taps = taps
        self.freq_xlating_fir_filter_xxx_0.set_taps(self.taps)

    def get_squelch(self):
        return self.squelch

    def set_squelch(self, squelch):
        self.squelch = squelch
        Qt.QMetaObject.invokeMethod(self._squelch_line_edit, "setText", Qt.Q_ARG("QString", eng_notation.num_to_str(self.squelch)))
        self.analog_pwr_squelch_xx_0.set_threshold(self.squelch)

    def get_sensitivity(self):
        return self.sensitivity

    def set_sensitivity(self, sensitivity):
        self.sensitivity = sensitivity
        Qt.QMetaObject.invokeMethod(self._sensitivity_line_edit, "setText", Qt.Q_ARG("QString", eng_notation.num_to_str(self.sensitivity)))

    def get_samples_per_symbol(self):
        return self.samples_per_symbol

    def set_samples_per_symbol(self, samples_per_symbol):
        self.samples_per_symbol = samples_per_symbol

    def get_noise(self):
        return self.noise

    def set_noise(self, noise):
        self.noise = noise
        Qt.QMetaObject.invokeMethod(self._noise_line_edit, "setText", Qt.Q_ARG("QString", eng_notation.num_to_str(self.noise)))
        self.channels_channel_model_0.set_noise_voltage(self.noise)

    def get_msg_str(self):
        return self.msg_str

    def set_msg_str(self, msg_str):
        self.msg_str = msg_str
        self.blocks_vector_source_x_0_0.set_data([0xAA, 0xAA]+list(ord(i) for i in self.msg_str)+1000*[0,], [])
        self.satellites_sync_to_pdu_packed_0.set_packlen(len(self.msg_str))

    def get_freq(self):
        return self.freq

    def set_freq(self, freq):
        self.freq = freq
        Qt.QMetaObject.invokeMethod(self._freq_line_edit, "setText", Qt.Q_ARG("QString", eng_notation.num_to_str(self.freq)))
        self.analog_sig_source_x_0.set_frequency(self.freq-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0.set_center_freq(self.freq-self.center_freq)
        self.qtgui_sink_x_0_0.set_frequency_range(self.freq, self.samp_rate)

    def get_center_freq(self):
        return self.center_freq

    def set_center_freq(self, center_freq):
        self.center_freq = center_freq
        self.analog_sig_source_x_0.set_frequency(self.freq-self.center_freq)
        self.freq_xlating_fir_filter_xxx_0.set_center_freq(self.freq-self.center_freq)
        self.qtgui_sink_x_0.set_frequency_range(self.center_freq, self.samp_rate)





def main(top_block_cls=top_block, options=None):

    if StrictVersion("4.5.0") <= StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    def quitting():
        tb.stop()
        tb.wait()

    qapp.aboutToQuit.connect(quitting)
    qapp.exec_()

if __name__ == '__main__':
    main()
