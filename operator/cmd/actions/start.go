package actions

import (
	"context"
	"log"

	sdkutils "github.com/Layr-Labs/eigensdk-go/utils"
	"github.com/urfave/cli/v2"
	"github.com/yetanotherco/aligned_layer/core/config"
	operator "github.com/yetanotherco/aligned_layer/operator/pkg"
)

var StartFlags = []cli.Flag{
	config.ConfigFileFlag,
}

var StartCommand = &cli.Command{
	Name:        "start",
	Description: "Service that sends proofs to verify by operator nodes.",
	Flags:       StartFlags,
	Action:      operatorMain,
}

func operatorMain(ctx *cli.Context) error {
	operatorConfigFilePath := ctx.String("config")
	operatorConfig := config.NewOperatorConfig(operatorConfigFilePath)
	err := sdkutils.ReadYamlConfig(operatorConfigFilePath, &operatorConfig)
	if err != nil {
		return err
	}

	operator, err := operator.NewOperatorFromConfig(*operatorConfig)
	if err != nil {
		return err
	}

	log.Println("Operator starting...")
	err = operator.Start(context.Background())
	if err != nil {
		return err
	}

	log.Println("Operator started")

	return nil
}
