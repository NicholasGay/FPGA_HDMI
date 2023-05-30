
library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity top is
  
  port(
        RSTN            : in std_logic;
        CLK_27M         : in std_logic;
        
        O_TMDS_CLK_P    : out std_logic;
        O_TMDS_CLK_N    : out std_logic;
        O_TMDS_DATA_P   : out std_logic_vector(2 downto 0);
        O_TMDS_DATA_N   : out std_logic_vector(2 downto 0);
                        
        --   LED0        : out std_logic;
        LED1            : out   std_logic;
        LED2            : out   std_logic;
        LED3            : out   std_logic
    );
end top;

architecture behavioural of top is
--*****************************************************************
--SIGNAL DECLARATIONS
--*****************************************************************
--debug
SIGNAL qLED1 : STD_LOGIC;
SIGNAL qLED2 : STD_LOGIC;
SIGNAL qLED3 : STD_LOGIC;
--signal
SIGNAL clk_px : STD_LOGIC;
SIGNAL h_sync_vga : STD_LOGIC;
SIGNAL v_sync_vga : STD_LOGIC;
SIGNAL disp_ena_vga : STD_LOGIC;
SIGNAL column_vga : INTEGER;
SIGNAL row_vga : INTEGER;
SIGNAL n_blank_vga : STD_LOGIC;
SIGNAL n_sync_vga : STD_LOGIC;

SIGNAL v_sync_o : STD_LOGIC;
SIGNAL h_sync_o : STD_LOGIC;

SIGNAL red_o : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL blue_o : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL green_o : STD_LOGIC_VECTOR(7 DOWNTO 0);





--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Component declration
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

begin
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--COMPONENT / Entity Inst
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_VGA_CONTROLLER : entity work.vga_controller
port map(
    pixel_clk => clk_px,  --pixel clock at frequency of VGA mode being used
    reset_n   => RSTN,  --active low asycnchronous reset
    h_sync    => h_sync_vga,  --horiztonal sync pulse
    v_sync    => v_sync_vga,  --vertical sync pulse
    disp_ena  => disp_ena_vga,  --display enable ('1' = display time, '0' = blanking time)
    column    => column_vga,    --horizontal pixel coordinate
    row       => row_vga,    --vertical pixel coordinate
    n_blank   => n_blank_vga,  --direct blacking output to DAC
    n_sync    => n_sync_vga --sync-on-green output to DAC
);

U_HW_IMAGE_GEN : entity work.hw_image_generator
PORT MAP(
    clk => clk_px,
    disp_ena => disp_ena_vga,  --display enable ('1' = display time, '0' = blanking time)
    row      => row_vga,    --row pixel coordinate
    column   => column_vga, --column pixel coordinate
    h_sync_in => h_sync_vga,
    v_sync_in => v_sync_vga,
    h_sync_o => h_sync_o,
    v_sync_o => v_sync_o,
    red      => red_o,  --red magnitude output to DAC
    green    => green_o, --green magnitude output to DAC
    blue     => blue_o--blue magnitude output to DAC
);

u_clk_gen: entity work.Gowin_rPLL
    port map (
        clkout => clk_px,
        clkin => CLK_27M
    );


u_dvi: entity work.DVI_TX_Top
	port map (
		I_rst_n => RSTN,
		I_rgb_clk => clk_px,
		I_rgb_vs => v_sync_o,
		I_rgb_hs => h_sync_o,
		I_rgb_de => disp_ena_vga,
		I_rgb_r => red_o,
		I_rgb_g => green_o,
		I_rgb_b => blue_o,
		O_tmds_clk_p => O_TMDS_CLK_P,
		O_tmds_clk_n => O_TMDS_CLK_N,
		O_tmds_data_p => O_TMDS_DATA_P,
		O_tmds_data_n => O_TMDS_DATA_N
	);
--PROCESS
LED3 <= not qLED3 when rising_edge(CLK_27M);
LED2 <= not qLED2 when rising_edge(CLK_27M);
LED1 <= not qLED1 when rising_edge(CLK_27M);

U1: process(CLK_27M)

variable version : std_logic_vector(3 downto 0);

begin

if rising_edge(CLK_27M) then
    if(RSTN = '0') then 
        version := x"C";
        qLED3 <= version(2);
        qLED2 <= version(1);
        qLED1 <= version(0);
        
    else

    end if;  

end if;
end process;








end behavioural;
