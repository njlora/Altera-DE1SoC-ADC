library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bouton is
port (
	CLOCK_50 : in std_logic;
	LEDR 		: out std_logic_vector(9 downto 0);
	SW 		: in std_logic_vector(9 downto 0);
	KEY 		: in std_logic_vector(3 downto 0);
	ADC_DOUT : in std_logic;
	ADC_SCLK : out std_logic;
	ADC_CS_N : out std_logic;
	ADC_DIN	: out std_logic;
	HEX5		: out std_logic_vector(6 downto 0)
);
end bouton;

architecture RTL of bouton is

component adv_adc is
	port (
		GO 		 : in std_logic;
		CLOCK     : in  std_logic;                     			--         clk.clk
		RESET     : in  std_logic;
		CHAN      : in std_logic_vector(2 downto 0);        --    CHAN
		DOUT 		 : in std_logic;
		SCLK  	 : out std_logic;                            -- adc_signals.SCLK
		CS_N  	 : out std_logic;									  --            .CS_N
		DIN		 : out std_logic
	);
end component adv_adc;
	
signal		sGO 			: std_logic;
signal		sCLOCK      : std_logic;                     			--         clk.clk
signal		sRESET      : std_logic;
signal		sCHAN       : std_logic_vector(2 downto 0);        --    CHAN
signal		sDOUT 		: std_logic;
signal		sSCLK  		: std_logic;                            -- adc_signals.SCLK
signal		sCS_N  		: std_logic;									  --            .CS_N
signal		sDIN			: std_logic;

begin

 signal_adc:adv_adc 
		port map (
		GO => sGO,
		RESET => sRESET,
		CLOCK => sCLOCK,
		CHAN => sCHAN,
		DOUT => sDOUT,
		CS_N => sCS_N,
		DIN => sDIN,
		SCLK => sSCLK
		);

sGO <= SW(0);
LEDR (0) <= sGO;
sRESET <= not KEY(0);
sCLOCK <= CLOCK_50;
sCHAN(2 downto 0) <= SW(9 downto 7);
sDOUT <= ADC_DOUT;
ADC_CS_N <= sCS_N;
ADC_DIN <= sDIN;
ADC_SCLK <= sSCLK;
LEDR(9 downto 7) <= SW(9 downto 7);
LEDR (1) <= sRESET;

Hex:Process (sCHAN)
begin
case sCHAN is
	when "000" => Hex5 <= "1000000";
	when "001" => Hex5 <= "1111001";
	when "010" => Hex5 <= "0100100";
	when "011" => Hex5 <= "0110000";
	when "100" => Hex5 <= "0011001";
	when "101" => Hex5 <= "0010010";
	when "110" => Hex5 <= "0000010";
	when "111" => Hex5 <= "1111000";
	when others => Hex5 <= "0000000";
end case;
end process;

end RTL;